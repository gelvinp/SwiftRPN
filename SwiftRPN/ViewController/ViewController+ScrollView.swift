//
//  ViewController+ScrollView.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/26/23.
//

import UIKit

extension ViewController : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        onScrollStarted()
    }
    
    func onScrollStarted() {
        if findSizeClass(with: traitCollection) == .Portrait {
            view.endEditing(true)
        }
    }
}
