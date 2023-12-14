//
//  NotifyingAlertController.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/25/23.
//

import UIKit

class ExtraButtonAlertController: UIAlertController {
    var tag: OperatorTag!
    var confirmCallback: ((ExtraButtonAssignment?)->())?
    var viewController: ViewController?
    
    convenience init(title: String?, message: String?, preferredStyle: UIAlertController.Style, tag: OperatorTag, confirmCallback: ((ExtraButtonAssignment?)->())?) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)
        self.tag = tag
        self.confirmCallback = confirmCallback
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let navController = presentingViewController as? UINavigationController,
           let viewController = navController.delegate as? ViewController {
            self.viewController = viewController
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewController?.alertIsPresented = false
    }
    
    func makeConfirmAction() -> UIAlertAction {
        UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let textFields = textFields else { return }
            guard let viewController = viewController else { return }
            
            guard let newLabel = textFields.first(where: { textField in
                textField.tag == 0
            })?.text else { return }
            guard let newAction = textFields.first(where: { textField in
                textField.tag == 1
            })?.text else { return }
            
            var buttons = Settings.shared.extraButtonData
            
            guard !newLabel.isEmpty else {
                viewController.display_error("Label cannot be empty!")
                viewController.updateMessageState()
                return
            }
            guard !newAction.isEmpty else {
                viewController.display_error("Action cannot be empty!")
                viewController.updateMessageState()
                return
            }
            
            guard newLabel.count < 12 else {
                viewController.display_error("Label is too long (max 12 characters)!")
                viewController.updateMessageState()
                return
            }
            guard newAction.count < 250 else {
                viewController.display_error("Action is too long (max 250 characters)!")
                viewController.updateMessageState()
                return
            }
            
            let newButton = ExtraButtonAssignment(label: newLabel, action: newAction)
            
            switch tag! {
            case OperatorTag.Extra11:
                buttons[0][0] = newButton
            case OperatorTag.Extra21:
                buttons[1][0] = newButton
            case OperatorTag.Extra31:
                buttons[2][0] = newButton
            case OperatorTag.Extra41:
                buttons[3][0] = newButton
            default:
                fatalError("Unexpected extra button tag during assignment")
            }
            
            Settings.shared.extraButtonData = buttons
            
            confirmCallback?(newButton)
        }
    }
}
