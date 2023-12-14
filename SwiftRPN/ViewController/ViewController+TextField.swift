//
//  ViewController+TextField.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/26/23.
//

import UIKit


extension ViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if alertIsPresented { return false }
        
        if keyboardIsNumeric {
            guard findSizeClass(with: traitCollection) == .Portrait else {
                guard landscapeKeyboard == nil else { return true }
                
                scratchpad.inputView = UIView()
                
                let keyboard = MathKeyboard(target: scratchpad, enableExtraButtons: true, viewController: self)
                keyboard.shouldInsetBounds = false
                keyboard.bounds = CGRect(x: 0, y: 0, width: 0, height: 240)
                
                keyboard.alpha = 0.0
                keyboard.isHidden = true
                inputStack.addArrangedSubview(keyboard)
                
                UIView.animate(
                    withDuration: 0.5,
                    delay: 0,
                    usingSpringWithDamping: 1.0,
                    initialSpringVelocity: 1.0,
                    options: [.curveEaseOut],
                    animations: {
                        keyboard.alpha = 1.0
                        keyboard.isHidden = false
                    })
                
                landscapeKeyboard = keyboard
                
                return true
            }
            
            let keyboard = MathKeyboard(target: scratchpad, viewController: self)
            keyboard.bounds = CGRect(x: 0, y: 0, width: 0, height: 240)
            
            scratchpad.inputView = UIView()
            scratchpad.inputAccessoryView = keyboard
        } else {
            switchKeyboardToAlphanumeric()
        }
        
        stackCollectionView.setShouldScrollToBottom()
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onScratchpadSubmit()
        return true
    }
}

extension ViewController {
    @objc func switchKeyboardToNumeric() {
        scratchpad.inputAccessoryView?.removeFromSuperview()
        scratchpad.inputView = nil
        scratchpad.inputAccessoryView = nil
        keyboardIsNumeric = true
        scratchpad.resignFirstResponder()
        scratchpad.becomeFirstResponder()
    }
    
    @objc func alphanumericBarButtonPressed(_ sender: UIBarButtonItem) {
        if let text = sender.title {
            scratchpad.insertText(text)
        }
    }
    
    @objc func prefixBarButtonPressed(_ sender: UIBarButtonItem) {
        if let text = sender.title {
            scratchpad.text = text.appending(scratchpad.text ?? "")
        }
    }
    
    func switchKeyboardToAlphanumeric() {
        scratchpad.inputAccessoryView?.removeFromSuperview()
        
        if let keyboard = landscapeKeyboard {
            inputStack.removeArrangedSubview(keyboard)
            keyboard.removeFromSuperview()
            landscapeKeyboard = nil
        }
        
        scratchpad.inputView = nil
        scratchpad.inputAccessoryView = nil
        
        let toolbar = UIToolbar(
            frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        
        let backButton = UIBarButtonItem(
            title: "Back", style: .done, target: self, action: #selector(switchKeyboardToNumeric))
        backButton.accessibilityLabel = "Return to simplified keyboard"
        
        let prefixItems = [
            ["0b", "Add binary prefix"],
            ["0o", "Add octal prefix"],
            ["0x", "Add hexadecimal prefix"]
        ].map { item in
            let button = UIBarButtonItem(
                title: item[0], style: .plain,
                target: self, action: #selector(prefixBarButtonPressed(_:)))
            
            button.accessibilityLabel = item[1]
            return button
        }
        
        let spacer = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let textItems = [
            ["\\", "Backslash"],
            ["_", "Underscore"],
            ["[", "Open square bracket"],
            ["]", "Close square bracket"],
            ["{", "Open curly brace"],
            ["}", "Close curly brace"]
        ].map { item in
            let button = UIBarButtonItem(
                title: item[0], style: .plain,
                target: self, action: #selector(alphanumericBarButtonPressed(_:)))
            
            button.accessibilityLabel = item[1]
            return button
        }
        
        toolbar.items = [backButton] + prefixItems + [spacer] + textItems
        
        scratchpad.inputAccessoryView = toolbar
        scratchpad.reloadInputViews()
        keyboardIsNumeric = false
    }
}
