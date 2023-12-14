//
//  ViewController+RCalcReceiver.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/26/23.
//

import SwiftUI

extension ViewController : RCalcReceiver {
    func display_info(_ info: String) {
        message = info
        
        switch desiredMessageState {
        case .hidden, .wantsToShowError, .showingError, .wantsToHide:
            desiredMessageState = .wantsToShowInfo
        default:
            break
        }
    }
    
    func display_error(_ error: String) {
        message = error
        
        switch desiredMessageState {
        case .hidden, .wantsToShowInfo, .showingInfo, .wantsToHide:
            desiredMessageState = .wantsToShowError
        default:
            break
        }
    }
    
    func clear_message() {
        message = nil
        
        switch desiredMessageState {
        case .wantsToShowError, .showingError, .wantsToShowInfo, .showingInfo:
            desiredMessageState = .wantsToHide
        default:
            break
        }
    }
    
    func try_render_command(_ command: String) -> Bool {
        switch command {
        case "\\clearhist":
            history = []
            historyState = nil
            return true
        case "\\queer":
            stackDataSource.queerActive.toggle()
            return true
        case "\\help":
            navigationController?.pushViewController(UIHostingController(rootView: MainHelpView()), animated: true)
            return true
        case "\\settings":
            navigationController?.pushViewController(UIHostingController(rootView: SettingsController()), animated: true)
            return true
        default:
            print("Unknown command: \(command)")
            return false
        }
    }
    
    func add_stack_item(_ item: SwiftStackItem) {
        stackDataSource.add_stack_item(item)
    }
    
    func remove_stack_item() {
        stackDataSource.remove_stack_item()
    }
    
    func clear_stack() {
        stackDataSource.clear_stack()
    }
}

extension ViewController {
    func updateMessageState() {
        if messageState == desiredMessageState { return }
        
        // If I animate things, new entries slide in from above instead of just appearing like they're supposed to?
        
        switch (messageState, desiredMessageState) {
        case (.hidden, .wantsToShowInfo):
            messageLabel.textColor = .mathKeyboardText
            stackCollectionView.setShouldScrollToBottom()
            messageStack.isHidden = false
            messageState = .showingInfo
        case (.hidden, .wantsToShowError):
            messageLabel.textColor = .red
            stackCollectionView.setShouldScrollToBottom()
            messageStack.isHidden = false
            messageState = .showingError
        case (.showingError, .wantsToShowInfo):
            messageLabel.textColor = .mathKeyboardText
            messageState = .showingError
        case (.showingInfo, .wantsToShowError):
            messageLabel.textColor = .red
            messageState = .showingError
        case (.showingInfo, .wantsToHide), (.showingError, .wantsToHide):
            stackCollectionView.setShouldScrollToBottom()
            messageStack.isHidden = true
            messageState = .hidden
        case (.showingInfo, .wantsToShowInfo): break
        case (.showingError, .wantsToShowError): break
        default:
            fatalError("Unexpected message state combination: from \(messageState) to \(desiredMessageState)!")
        }
        
        desiredMessageState = messageState
    }
}
