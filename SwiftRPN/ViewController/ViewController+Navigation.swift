//
//  ViewController+NavigationDelegate.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/26/23.
//

import UIKit

extension ViewController : UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        navigationController.setNavigationBarHidden(viewController == self, animated: true)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController == self && loaded && findSizeClass(with: traitCollection) == .Landscape {
            setConstraints()
            scratchpad.becomeFirstResponder()
        }
    }
}
