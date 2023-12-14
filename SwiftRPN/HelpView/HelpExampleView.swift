//
//  HelpExampleView.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/22/23.
//

import SwiftUI


struct HelpExampleView : UIViewRepresentable {
    typealias UIViewType = StackItemView
    
    let stackItem: SwiftStackItem
    
    func makeUIView(context: Context) -> StackItemView {
        let view = StackItemView(stackItem: stackItem, example: true)
        
//        view.setForegroundColor(.secondaryLabel)
        
        return view
    }
    
    func updateUIView(_ uiView: StackItemView, context: Context) {
        //
    }
}
