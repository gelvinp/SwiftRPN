//
//  CopyableLabel.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 12/12/23.
//

import UIKit


class CopyableLabel : UILabel, UIEditMenuInteractionDelegate {
    private var editMenuInteraction: UIEditMenuInteraction? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = true
        
        self.editMenuInteraction = UIEditMenuInteraction(delegate: self)
        addInteraction(editMenuInteraction!)
        
        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(onLongPress(_:))
        )
        longPress.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        addGestureRecognizer(longPress)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
                             
    @objc func onLongPress(_ recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.location(in: self)
        let configuration = UIEditMenuConfiguration(identifier: nil, sourcePoint: location)
        
        if let interaction = editMenuInteraction {
            interaction.presentEditMenu(with: configuration)
        }
    }
    
    func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {
        let copyAction = UIAction(title: "Copy") { [weak self] (action) in
            if let text = self?.text {
                UIPasteboard.general.string = text
            }
        }
        
        return UIMenu(children: [copyAction])
    }
}
