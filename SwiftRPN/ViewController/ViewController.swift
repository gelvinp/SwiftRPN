//
//  ViewController.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/2/23.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var inputBackground: UIView!
    @IBOutlet var inputTopAnchor: UIView!
    @IBOutlet var inputStack: UIStackView!
    @IBOutlet var messageStack: UIStackView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var scratchpad: Scratchpad!
    
    var message: String? = "Welcome to SwiftRPN! Type \\help to see what commands and operators are supported." {
        didSet {
            if let message = message {
                messageLabel.text = message
            }
        }
    }
    
    enum MessageState {
        case hidden
        case wantsToShowInfo
        case wantsToShowError
        case showingInfo
        case showingError
        case wantsToHide
    }
    var messageState = MessageState.showingInfo
    var desiredMessageState = MessageState.showingInfo
    
    let gradient = CAGradientLayer()
    var stackCollectionLayout: UICollectionViewFlowLayout!
    var stackCollectionView: StackCollectionView!
    var stackDataSource: StackCollectionDataSource!
    
    var keyboardIsNumeric = true
    
    var history: [String] = []
    var historyState: Int? = nil
    
    let autocomp = AutoComp()
    
    var portraitConstraints: [NSLayoutConstraint] = []
    var landscapeConstraints: [NSLayoutConstraint] = []
    var edgeConstraints: [NSLayoutConstraint] = []
    var landscapeKeyboard: MathKeyboard? = nil
    var lastSeenOrientation: UIDeviceOrientation?
    
    public var alertIsPresented = false {
        didSet {
            if alertIsPresented == false {
                scratchpad.becomeFirstResponder()
            }
        }
    }
    
    var loaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        RCalcBridge.shared.set_receiver(receiver: self)
        
        // Collection view
        stackCollectionLayout = StackCollectionLayout()
        stackCollectionLayout.scrollDirection = .vertical
        
        stackCollectionView = StackCollectionView(frame: .zero, collectionViewLayout: stackCollectionLayout)
        stackCollectionView.keyboardDismissMode = .interactiveWithAccessory
        stackCollectionView.allowsSelection = false
        stackCollectionView.backgroundColor = nil
        stackCollectionView.backgroundView = nil
        
        stackDataSource = StackCollectionDataSource(collectionView: stackCollectionView)
        stackDataSource.onScrollStarted = onScrollStarted
        stackCollectionView.delegate = stackDataSource
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupLayout()
        setConstraints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(detectLandscapeRotation), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scratchpad.becomeFirstResponder()
        loaded = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateGradientAppearance()
    }
    
    func onScratchpadSubmit() {
        clear_message()
        
        if let text = scratchpad.text, !text.isEmpty {
            history.append(text)
            historyState = nil
            
            RCalcSubmitText(text.lowercased())
            scratchpad.text = nil
        } else {
            RCalcSubmitText("\\dup")
        }
        
        updateMessageState()
        stackDataSource.applySnapshot()
    }
    
    func submitText(_ text: String) {
        clear_message()
        RCalcSubmitText(text.lowercased())
        
        updateMessageState()
        stackDataSource.applySnapshot()
    }
    
    func submitOperator(_ op: String) {
        clear_message()
        
        if let text = scratchpad.text, !text.isEmpty {
            RCalcSubmitText(text.lowercased())
            scratchpad.text = nil
        }
        
        RCalcSubmitText(op)
        
        updateMessageState()
        stackDataSource.applySnapshot()
    }
    
    @objc func updateGradientAppearance() {
        gradient.colors = [
            UIColor.backgroundGradientStart.cgColor,
            UIColor.backgroundGradientEnd.cgColor
        ]
    }
    
    @IBAction func onAutocompleteForward(_ sender: UISwipeGestureRecognizer) {
        if (!autocomp.suggestionsActive()) {
            guard let text = scratchpad.text, !text.isEmpty else {
                return
            }
            autocomp.initSuggestions(text)
        }
        
        let next = autocomp.getNextSuggestion()
        if (next == nil) { return }
        
        scratchpad.text = next
    }
    
    @IBAction func onAutocompleteBackward(_ sender: UISwipeGestureRecognizer) {
        if (!autocomp.suggestionsActive()) {
            guard let text = scratchpad.text, !text.isEmpty else {
                return
            }
            autocomp.initSuggestions(text)
        }
        
        let next = autocomp.getPreviousSuggestion()
        if (next == nil) { return }
        
        scratchpad.text = next
    }
    
    @IBAction func onHistoryPrevious(_ sender: UISwipeGestureRecognizer) {
        var nextState: Int
        
        if let state = historyState {
            nextState = state + 1
            if nextState > history.count { return }
        }
        else if !history.isEmpty {
            nextState = 1
        }
        else { return }
        
        scratchpad.text = history[history.count - nextState]
        historyState = nextState
    }
    
    @IBAction func onHistoryNext(_ sender: UISwipeGestureRecognizer) {
        var nextState: Int? = nil
        
        if let state = historyState {
            nextState = state - 1
            if nextState == 0 { nextState = nil }
            if (nextState ?? 0) > history.count { nextState = nil }
        }
        else { return }
        
        if let nextState = nextState {
            scratchpad.text = history[history.count - nextState]
        }
        else { scratchpad.text = "" }
        
        historyState = nextState
    }
    
    @objc func onScratchpadContentsChanged() {
        autocomp.cancelSuggestion()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        let sizeClass = findSizeClass(with: newCollection)
        
        coordinator.animate(alongsideTransition: { [weak self] (context) in
            self?.setConstraints(sizeClass: sizeClass)
        }, completion: { [weak self] (context) in
            self?.stackCollectionView.setShouldScrollToBottom(immediately: true)
            self?.scratchpad.becomeFirstResponder()
        })
    }
    
    @objc func detectLandscapeRotation() {
        guard let lastSeenOrientation = lastSeenOrientation else {
            lastSeenOrientation = UIDevice.current.orientation
            return
        }
        
        let orientation = UIDevice.current.orientation
        
        if (lastSeenOrientation == .landscapeLeft && orientation == .landscapeRight) ||
            (lastSeenOrientation == .landscapeRight && orientation == .landscapeLeft) {
            setConstraints()
            scratchpad.becomeFirstResponder()
        }
    }
    
    func showAlert(_ alert: UIAlertController) {
        alertIsPresented = true
        present(alert, animated: true)
    }
}
