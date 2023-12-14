//
//  StackScrollView.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/6/23.
//

import UIKit

class StackScrollView: UIScrollView {
    var stack = UIStackView(frame: .zero)
    
    override var bounds: CGRect {
        didSet {
            maybeScrollToBottom()
        }
    }
    
    public var queerActive: Bool = Settings.shared.colorTheme == .Queer {
        didSet {
            updateQueer()
        }
    }
    
    private var lastContentSize = CGSize.zero
    private var shouldScrollToBottom = false
    private var itemAdded = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        keyboardDismissMode = .interactiveWithAccessory
        
        stack.axis = .vertical
        stack.contentMode = .bottom
        stack.spacing = 16
        
        let spacer = UIView()
        spacer.setContentHuggingPriority(.init(1), for: .vertical)
        stack.addArrangedSubview(spacer)
        
        addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stack.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        stack.heightAnchor.constraint(greaterThanOrEqualTo: heightAnchor).isActive = true
        
        Settings.shared.subscribe(to: \.colorTheme) { [weak self] in
            self?.queerActive = Settings.shared.colorTheme == .Queer
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateInputBackgrounds()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentSize = stack.bounds.size
        
        if lastContentSize != contentSize {
            maybeScrollToBottom()
            lastContentSize = contentSize
        }
    }
    
    func maybeScrollToBottom() {
        if shouldScrollToBottom || itemAdded {
            let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
            if(bottomOffset.y > 0) {
                setContentOffset(bottomOffset, animated: true)
            }
            
            itemAdded = false
            shouldScrollToBottom = false
        }
    }
    
    public func addStackItem(_ stackItem: SwiftStackItem) {
        let view = StackItemView(stackItem: stackItem)
        
        if queerActive {
            let index = stack.arrangedSubviews.count - 1
            view.setForegroundColor(StackColor.foreground(with: index))
            view.setBackgroundColor(StackColor.background(with: index, style: traitCollection.userInterfaceStyle))
        }
        
        itemAdded = true
        stack.addArrangedSubview(view)
    }
    
    public func removeLastStackItem() {
        if let view = stack.arrangedSubviews.last {
            guard view is StackItemView else { return }
            stack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    public func removeAllStackItems() {
        for view in stack.arrangedSubviews {
            guard view is StackItemView else { continue }
            stack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    public func setShouldScrollToBottom(immediately: Bool = false) {
        shouldScrollToBottom = true
        
        if immediately {
            maybeScrollToBottom()
        }
    }
    
    @objc
    func updateInputBackgrounds() {
        if !queerActive { return }
        for (index, view) in stack.arrangedSubviews.enumerated() {
            guard let view = view as? StackItemView else { continue }
            view.setBackgroundColor(StackColor.background(with: index - 1, style: traitCollection.userInterfaceStyle))
        }
    }
    
    func updateQueer() {
        for (index, view) in stack.arrangedSubviews.enumerated() {
            guard let view = view as? StackItemView else { continue }
            
            if queerActive {
                view.setForegroundColor(StackColor.foreground(with: index - 1))
                view.setBackgroundColor(StackColor.background(with: index - 1, style: traitCollection.userInterfaceStyle))
            }
            else {
                view.setForegroundColor(.mathKeyboardText)
                view.setBackgroundColor(.clear)
            }
        }
    }
}
