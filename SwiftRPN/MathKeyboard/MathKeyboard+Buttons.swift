//
//  MathKeyboard+Buttons.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/26/23.
//

import UIKit

extension MathKeyboard {
    internal func makeButton(digit: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(String(format: "%d", digit), for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .largeTitle)
        button.setTitleColor(.mathKeyboardText, for: .normal)
        button.accessibilityTraits = [.keyboardKey]
        button.tag = digit
        button.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        return button
    }
    
    internal func makeButton(imageName: String, tag: OperatorTag) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.tintColor = .mathKeyboardText
        let symbolConf = button
            .preferredSymbolConfigurationForImage(in: .normal)?
            .applying(UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .title2)))
        button.setPreferredSymbolConfiguration(symbolConf, forImageIn: .normal)
        button.accessibilityTraits = [.keyboardKey]
        button.tag = tag.rawValue
        button.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        return button
    }
    
    internal func makeButton(text: String, tag: OperatorTag) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .largeTitle)
        button.setTitleColor(.mathKeyboardText, for: .normal)
        button.accessibilityTraits = [.keyboardKey]
        button.tag = tag.rawValue
        button.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        return button
    }
    
    internal func makeButton(assignment: ExtraButtonAssignment?, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(assignment?.label ?? "", for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitleColor(.mathKeyboardText, for: .normal)
        button.accessibilityTraits = [.keyboardKey]
        button.accessibilityLabel = assignment?.label ?? "Unassigned Button"
        button.tag = tag
        
        if assignment == nil {
            button.addTarget(self, action: #selector(onButtonPressedWhileUnassigned(_:)), for: .touchUpInside)
        }
        else {
            button.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        }
        
        return button
    }
    
    internal func makeExtraButtons(assignments: [ExtraButtonAssignment?], firstTag: OperatorTag) -> UIStackView {
        let rowButtons = UIStackView()
        rowButtons.axis = .horizontal
        rowButtons.alignment = .fill
        rowButtons.distribution = .fillEqually
        
        var tagValue = firstTag.rawValue
        
        for assignment in assignments {
            let button = makeButton(assignment: assignment, tag: tagValue)
            
            button.accessibilityCustomActions = [
                UIAccessibilityCustomAction(name: "Assign Button") { [weak self] _ in
                    self?.onButtonRequestsAssignment(button)
                    return true
                }
            ]
            
            button.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(onButtonRequestsAssignment(_:))))
            
            rowButtons.addArrangedSubview(button)
            
            tagValue += 1
        }
        
        rowButtons.translatesAutoresizingMaskIntoConstraints = false
        
        return rowButtons
    }
    
    @objc func onButtonPressed(_ sender: UIButton) {
        let tag = sender.tag
        
        if (tag < 10) {
            target?.insertText(String(format: "%d", tag))
        }
        else if let op_tag = OperatorTag(rawValue: tag) {
            switch op_tag {
            case .Add:
                viewController?.submitOperator("add")
            case .Sub:
                viewController?.submitOperator("sub")
            case .Mul:
                viewController?.submitOperator("mul")
            case .Div:
                viewController?.submitOperator("div")
            case .Del:
                if let text = target?.text, !text.isEmpty {
                    target?.deleteBackward()
                } else {
                    viewController?.submitText("\\pop")
                }
            case .Dot:
                target?.insertText(".")
            case .Abc:
                viewController?.switchKeyboardToAlphanumeric()
            case .Ret:
                viewController?.onScratchpadSubmit()
            case .Neg:
                if let text = target?.text, !text.isEmpty {
                    if text.first == "-" {
                        target?.text = String(text.dropFirst())
                    } else {
                        target?.text = "-".appending(text)
                    }
                } else {
                    viewController?.submitText("neg")
                }
            case .Extra11:
                guard let action = Settings.shared.extraButtonData[0][0]?.action else { return }
                if let text = target?.text, !text.isEmpty {
                    viewController?.submitText(text)
                    target?.text = ""
                }
                for line in action.split(separator: ";") {
                    viewController?.submitText(String(line))
                }
            case .Extra21:
                guard let action = Settings.shared.extraButtonData[1][0]?.action else { return }
                if let text = target?.text, !text.isEmpty {
                    viewController?.submitText(text)
                    target?.text = ""
                }
                for line in action.split(separator: ";") {
                    viewController?.submitText(String(line))
                }
            case .Extra31:
                guard let action = Settings.shared.extraButtonData[2][0]?.action else { return }
                if let text = target?.text, !text.isEmpty {
                    viewController?.submitText(text)
                    target?.text = ""
                }
                for line in action.split(separator: ";") {
                    viewController?.submitText(String(line))
                }
            case .Extra41:
                guard let action = Settings.shared.extraButtonData[3][0]?.action else { return }
                if let text = target?.text, !text.isEmpty {
                    viewController?.submitText(text)
                    target?.text = ""
                }
                for line in action.split(separator: ";") {
                    viewController?.submitText(String(line))
                }
            }
        }
    }
    
    @objc func onButtonPressedWhileUnassigned(_ sender: NSObject) {
        viewController?.display_info("Tap and hold to assign this button.")
    }
    
    @objc func onButtonRequestsAssignment(_ sender: NSObject) {
        let tag: OperatorTag
        if let sender = sender as? UIButton {
            tag = OperatorTag(rawValue: sender.tag)!
        }
        else if let sender = sender as? UILongPressGestureRecognizer, let b_tag = sender.view?.tag {
            guard sender.state == .began else { return }
            tag = OperatorTag(rawValue: b_tag)!
        }
        else {
            return
        }
        print("Requesting assignment for button \(tag)")
        
        let currentButtons = Settings.shared.extraButtonData
        let currentButton: ExtraButtonAssignment?
        
        switch tag {
        case OperatorTag.Extra11:
            currentButton = currentButtons[0][0]
        case OperatorTag.Extra21:
            currentButton = currentButtons[1][0]
        case OperatorTag.Extra31:
            currentButton = currentButtons[2][0]
        case OperatorTag.Extra41:
            currentButton = currentButtons[3][0]
        default:
            fatalError("Unexpected extra button tag during assignment")
        }
        
        let alert = ExtraButtonAlertController(title: "Set Extra Button", message: "Choose the button label and action. Use ';' to separate multiple actions.", preferredStyle: .alert, tag: tag) { [weak self] _ in
            self?.refreshKeyboard()
        }
        
        alert.addTextField() { textField in
            textField.placeholder = "Label"
            textField.text = currentButton?.label
            textField.tag = 0
        }
        
        alert.addTextField() { textField in
            textField.placeholder = "Action"
            textField.text = currentButton?.action
            textField.tag = 1
        }
        
        alert.addAction(alert.makeConfirmAction())
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        viewController?.showAlert(alert)
    }
}
