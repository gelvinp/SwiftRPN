//
//  StackItemView.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/6/23.
//

import UIKit

class StackItemView: UIView {
    private var entry: DisplayEntry
    
    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: bounds.width, height: entry.height)
        }
    }
    
    let example: Bool
    
    init(stackItem: SwiftStackItem, example: Bool = false) {
        self.entry = DisplayEntry(stackItem: stackItem, outputCopyable: !example)
        self.example = example
        super.init(frame: .zero)
        
        calculateSize()
        
        addSubview(entry.output.label)
        for chunk in entry.input.chunks {
            addSubview(chunk.label)
        }
        
        layer.addSublayer(entry.input.backgroundLayer)
        if let outputBackgroundLayer = entry.output.backgroundLayer {
            layer.addSublayer(outputBackgroundLayer)
        }
        
        isAccessibilityElement = true
        accessibilityLabel = "Stack Value"
        accessibilityValue = stackItem.accessibilityValue
        
        accessibilityCustomActions = [
            UIAccessibilityCustomAction(name: "Copy to pasteboard") { [weak self] _ in
                if let text = self?.entry.output.label.text {
                    UIPasteboard.general.string = text
                }
                return true
            }
        ]
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        calculateSize()
        super.layoutSubviews()
    }
    
    public func setForegroundColor(_ color: UIColor) {
        for chunk in entry.input.chunks {
            chunk.label.textColor = color
        }
        entry.output.label.textColor = color
    }
    
    public func setBackgroundColor(_ color: UIColor) {
        entry.input.backgroundLayer.backgroundColor = color.cgColor
        entry.output.backgroundLayer?.backgroundColor = color.cgColor
    }
    
    private func calculateSize() {
        if bounds.width > 0 {
            entry.calculateSize(maxWidth: bounds.width, example: example)
        }
        invalidateIntrinsicContentSize()
    }
}
