//
//  ViewController+Layout.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/26/23.
//

import UIKit

extension ViewController {
    enum SizeClass {
        case Portrait
        case Landscape
    }
    
    internal func findSizeClass(with traits: UITraitCollection) -> SizeClass {
        let h = traits.horizontalSizeClass
        let v = traits.verticalSizeClass
        
        if (h == .compact && v == .regular) {
            return .Portrait
        }
        else {
            return .Landscape
        }
    }
    
    func setupLayout() {
        // Background gradient setup
        gradient.frame = backgroundView.frame
        gradient.colors = [
            UIColor.backgroundGradientStart.cgColor,
            UIColor.backgroundGradientEnd.cgColor
        ]
        
        backgroundView.layer.addSublayer(gradient)
        
        let shadowRect = CGRect(
            x: inputBackground.bounds.minX - 8,
            y: inputBackground.bounds.minY,
            width: inputBackground.bounds.width + 16,
            height: view.bounds.height
        )
        inputBackground.layer.shadowPath = UIBezierPath(roundedRect: shadowRect, cornerRadius: 24).cgPath
        
        // Input Background setup
        inputBackground.layer.cornerRadius = 24
        
        // Extend the shadow horizontally
        inputBackground.layer.shadowColor = UIColor.black.cgColor
        inputBackground.layer.shadowOpacity = 0.25
        inputBackground.layer.shadowRadius = 8
        
        portraitConstraints.append(inputBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        portraitConstraints.append(inputBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        inputStack.leadingAnchor.constraint(equalTo: inputBackground.leadingAnchor, constant: 32).isActive = true
        portraitConstraints.append(inputStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32))
        
        portraitConstraints.append(inputTopAnchor.heightAnchor.constraint(equalToConstant: 0))
        
        // Scratchpad setup
        scratchpad.font = Constants.StackItemFont
        scratchpad.delegate = self
        scratchpad.becomeFirstResponder()
        scratchpad.addTarget(self, action: #selector(onScratchpadContentsChanged), for: .editingChanged)
        scratchpad.accessibilityCustomActions = [
            UIAccessibilityCustomAction(name: "Autocomplete Previous Suggestion", target: self, selector: #selector(onAutocompleteBackward(_:))),
            UIAccessibilityCustomAction(name: "Autocomplete Next Suggestion", target: self, selector: #selector(onAutocompleteForward(_:))),
            UIAccessibilityCustomAction(name: "History Previous Entry", target: self, selector: #selector(onHistoryPrevious(_:))),
            UIAccessibilityCustomAction(name: "History Next Entry", target: self, selector: #selector(onHistoryNext(_:)))
        ]
        
        // Keyboard avoidance
        view.keyboardLayoutGuide.topAnchor.constraint(
            equalToSystemSpacingBelow: inputStack.bottomAnchor, multiplier: 1.0).isActive = true
        
        // Scroll view setup
        view.addSubview(stackCollectionView)
        stackCollectionView.translatesAutoresizingMaskIntoConstraints = false
        portraitConstraints.append(stackCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        portraitConstraints.append(stackCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        portraitConstraints.append(stackCollectionView.bottomAnchor.constraint(equalTo: inputBackground.topAnchor, constant: -16))
        stackCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        landscapeConstraints.append(stackCollectionView.trailingAnchor.constraint(equalTo: inputBackground.leadingAnchor, constant: -16))
        landscapeConstraints.append(stackCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
        landscapeConstraints.append(inputBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        landscapeConstraints.append(inputBackground.topAnchor.constraint(equalTo: view.topAnchor))
    }
    
    func setConstraints(sizeClass: SizeClass? = nil) {
        for constraint in portraitConstraints {
            constraint.isActive = false
        }
        for constraint in landscapeConstraints {
            constraint.isActive = false
        }
        for constraint in edgeConstraints {
            constraint.isActive = false
        }
        edgeConstraints = []
        
        if let keyboard = landscapeKeyboard {
            inputStack.removeArrangedSubview(keyboard)
            keyboard.removeFromSuperview()
            landscapeKeyboard = nil
        }
        
        scratchpad.inputAccessoryView?.isHidden = true
        scratchpad.resignFirstResponder()
        scratchpad.inputView = nil
        scratchpad.inputAccessoryView = nil
        
        let sizeClass = sizeClass ?? findSizeClass(with: traitCollection)
        
        switch sizeClass {
        case .Portrait:
            for constraint in portraitConstraints {
                constraint.isActive = true
            }
            inputBackground.layer.shadowOffset = CGSize(width: 0, height: -8)
        case .Landscape:
            for constraint in landscapeConstraints {
                constraint.isActive = true
            }
            inputBackground.layer.shadowOffset = CGSize(width: 0, height: 0)
            
            if UIDevice.current.orientation == .landscapeLeft {
                edgeConstraints.append(stackCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor))
                edgeConstraints.append(inputStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32))
            } else {
                edgeConstraints.append(stackCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8))
                edgeConstraints.append(inputStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor))
            }
            
            let extraColumnCount = Settings.shared.extraCols
            if extraColumnCount == 2 {
                edgeConstraints.append(inputStack.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.0))
            }
            else if extraColumnCount == 1 {
                edgeConstraints.append(inputStack.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.0))
            }
            else {
                edgeConstraints.append(inputStack.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7))
            }
            
            for constraint in edgeConstraints {
                constraint.isActive = true
            }
        }
        
        lastSeenOrientation = UIDevice.current.orientation
        
        backgroundView.layoutIfNeeded()
        gradient.frame = CGRect(origin: .zero, size: backgroundView.frame.size)
    }
}
