//
//  tintedTextField.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/5/23.
//

import UIKit

class Scratchpad: UITextField {
    override func didAddSubview(_ subview: UIView) {
        if let button = subview as? UIButton {
            button.setImage(
                button.image(for: .normal)?.withTintColor(UIColor.scratchpadClearTint),
                for: .normal)
            button.setImage(
                button.image(for: .highlighted)?.withTintColor(UIColor.scratchpadClearTint),
                for: .highlighted)
        }
    }
}
