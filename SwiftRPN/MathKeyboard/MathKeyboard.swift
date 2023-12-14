//
//  MathKeyboard.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/5/23.
//

import UIKit

class MathKeyboard: UIView {
    weak var target: (UIKeyInput & UITextField)?
    weak var viewController: ViewController?
    
    public var shouldInsetBounds = true
    
    var vstack = UIStackView()
    let enableExtraButtons: Bool
    
    init(target: UIKeyInput & UITextField, enableExtraButtons: Bool = false, viewController: ViewController) {
        self.target = target
        self.enableExtraButtons = enableExtraButtons
        self.viewController = viewController
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !subviews.contains(vstack) {
            layoutKeyboard()
        }
        
        guard bounds != .zero else { return }
        
        if shouldInsetBounds {
            vstack.frame = bounds.insetBy(dx: 32, dy: 16).offsetBy(dx: 0, dy: -16)
        }
        else {
            vstack.frame = bounds
        }
    }
    
    func refreshKeyboard() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        self.vstack = UIStackView()
        self.layoutKeyboard()
    }
}
