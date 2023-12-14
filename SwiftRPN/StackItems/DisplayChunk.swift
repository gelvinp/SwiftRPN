//
//  DisplayChunk.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/14/23.
//

import UIKit


class DisplayChunk {
    public let label: UILabel
    public let backgroundLayer: CALayer?
    
    var frame: CGRect = .zero {
        didSet {
            label.frame = frame
            backgroundLayer?.frame = frame.insetBy(dx: -2, dy: -2)
        }
    }
    
    init(text: String = "", withBackgroundLayer: Bool = false, copyable: Bool = false) {
        if copyable {
            self.label = CopyableLabel(frame: .zero)
        }
        else {
            self.label = UILabel(frame: .zero)
        }
        label.text = text
        label.font = Constants.StackItemFont
        label.numberOfLines = 0
        label.textColor = .mathKeyboardText
        label.isAccessibilityElement = false
        
        if withBackgroundLayer {
            let backgroundLayer = CALayer()
            backgroundLayer.backgroundColor = UIColor.clear.cgColor
            backgroundLayer.zPosition = -1
            backgroundLayer.name = "StackItemBackgroundLayer"
            self.backgroundLayer = backgroundLayer
        }
        else {
            self.backgroundLayer = nil
        }
    }
    
    public func calculateSize(maxWidth: CGFloat = .greatestFiniteMagnitude) {
        let maxSize = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let attributes = [NSAttributedString.Key.font: Constants.StackItemFont]
        let text = (label.text ?? "") as NSString
        let size = text.boundingRect(
            with: maxSize, options: .usesLineFragmentOrigin,
            attributes: attributes, context: nil)
        
        let ceilSize = CGSize(width: ceil(size.width), height: ceil(size.height))
        frame = CGRect(origin: .zero, size: ceilSize)
    }
}
