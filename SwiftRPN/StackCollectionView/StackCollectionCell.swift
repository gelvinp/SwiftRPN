//
//  StackCollectionCell.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 12/14/23.
//

import UIKit


fileprivate extension UIConfigurationStateCustomKey {
    static let stackItem = UIConfigurationStateCustomKey("dev.gelvin.rcalc.stackItem")
    static let itemForegroundColor = UIConfigurationStateCustomKey("dev.gelvin.rcalc.itemForegroundColor")
    static let itemBackgroundColor = UIConfigurationStateCustomKey("dev.gelvin.rcalc.itemBackgroundColor")
}

private extension UICellConfigurationState {
    var stackItem: SwiftStackItem? {
        set { self[.stackItem] = newValue }
        get { return self[.stackItem] as? SwiftStackItem }
    }
    
    var itemForegroundColor: UIColor? {
        set { self[.itemForegroundColor] = newValue }
        get { return self[.itemForegroundColor] as? UIColor }
    }
    
    var itemBackgroundColor: UIColor? {
        set { self[.itemBackgroundColor] = newValue }
        get { return self[.itemBackgroundColor] as? UIColor }
    }
}

class StackItemListCell : UICollectionViewListCell {
    private var stackItem: SwiftStackItem? = nil
    private var itemForegroundColor: UIColor? = nil
    private var itemBackgroundColor: UIColor? = nil
    
    func updateWithItem(_ newItem: SwiftStackItem, foregroundColor: UIColor? = nil, backgroundColor: UIColor? = nil) {
        guard stackItem != newItem else { return }
        
        stackItem = newItem
        itemForegroundColor = foregroundColor
        itemBackgroundColor = backgroundColor
        
        setNeedsUpdateConfiguration()
    }
    
    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        
        state.stackItem = self.stackItem
        state.itemForegroundColor = self.itemForegroundColor
        state.itemBackgroundColor = self.itemBackgroundColor
        
        return state
    }
}


class StackCollectionCell : StackItemListCell {
    var entry: DisplayEntry? = nil
    
    override var intrinsicContentSize: CGSize {
        get {
            if let entry = entry {
                return CGSize(width: bounds.width, height: entry.height)
            }
            return .zero
        }
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        for sublayer in layer.sublayers ?? [] {
            guard sublayer.name == "StackItemBackgroundLayer" else { continue }
            sublayer.removeFromSuperlayer()
        }
        
        for view in contentView.subviews {
            view.removeFromSuperview()
        }
        
        backgroundColor = nil
        contentView.backgroundColor = nil
        
        guard let item = state.stackItem else { return }
        let foregroundColor = state.itemForegroundColor ?? .mathKeyboardText
        let backgroundColor = state.itemBackgroundColor ?? .clear
        
        let entry = DisplayEntry(stackItem: item)
        
        calculateSize()
        
        contentView.addSubview(entry.output.label)
        entry.output.label.textColor = foregroundColor
        entry.output.backgroundLayer?.backgroundColor = backgroundColor.cgColor
        
        for chunk in entry.input.chunks {
            contentView.addSubview(chunk.label)
            chunk.label.textColor = foregroundColor
        }
        entry.input.backgroundLayer.backgroundColor = backgroundColor.cgColor
        
        layer.addSublayer(entry.input.backgroundLayer)
        if let outputBackgroundLayer = entry.output.backgroundLayer {
            layer.addSublayer(outputBackgroundLayer)
        }
        
        isAccessibilityElement = true
        accessibilityLabel = "Stack Value"
        accessibilityValue = item.accessibilityValue
        
        accessibilityCustomActions = [
            UIAccessibilityCustomAction(name: "Copy to pasteboard") { _ in
                if let text = entry.output.label.text {
                    UIPasteboard.general.string = text
                }
                return true
            }
        ]
        
        self.entry = entry
    }
    
    override func layoutSubviews() {
        calculateSize()
        super.layoutSubviews()
        contentView.frame.origin.x = 0
    }
    
    private func calculateSize() {
        if bounds.width > 0 {
            entry?.calculateSize(maxWidth: bounds.width)
        }
        invalidateIntrinsicContentSize()
    }
}
