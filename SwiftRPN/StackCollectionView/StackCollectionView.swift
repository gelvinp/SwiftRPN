//
//  StackCollectionView.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 12/14/23.
//

import UIKit


class StackCollectionView : UICollectionView {
    override var bounds: CGRect {
        didSet {
            maybeScrollToBottom()
        }
    }
    
    private var lastContentSize = CGSize.zero
    private var shouldScrollToBottom = false
    var itemAdded = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let contentSize = collectionViewLayout.collectionViewContentSize
        var contentInsetTop = bounds.size.height

            contentInsetTop -= contentSize.height
            if contentInsetTop <= 0 {
                contentInsetTop = 0
        }
        contentInset = UIEdgeInsets(top: contentInsetTop, left: 0, bottom: 0, right: 0)
        
        if lastContentSize != contentSize {
            maybeScrollToBottom()
            
            let reloadNeeded = contentSize.width != lastContentSize.width
            lastContentSize = contentSize
            if reloadNeeded {
                reloadData()
            }
        }
    }
    
    func maybeScrollToBottom() {
        if shouldScrollToBottom || itemAdded {
            let lastIndex = numberOfItems(inSection: 0) - 1
            let indexPath = IndexPath(item: lastIndex, section: 0)
            scrollToItem(at: indexPath, at: .bottom, animated: true)
            
            itemAdded = false
            shouldScrollToBottom = false
        }
    }
    
    public func setShouldScrollToBottom(immediately: Bool = false) {
        shouldScrollToBottom = true
        
        if immediately {
            maybeScrollToBottom()
        }
    }
}
