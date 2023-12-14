//
//  DisplayEntry.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/14/23.
//

import Foundation


class DisplayEntry {
    public var input: DisplayLine
    public var output: DisplayChunk
    public var height: CGFloat = 0.0
    
    init(stackItem: SwiftStackItem, outputCopyable: Bool = true) {
        self.input = DisplayLine(chunks: stackItem.input)
        self.output = DisplayChunk(text: stackItem.output, withBackgroundLayer: true, copyable: outputCopyable)
    }
    
    public func calculateSize(maxWidth: CGFloat?, example: Bool = false) {
        var availableWidth = 0.0
        let outputOnNewLine: Bool
        
        if !example {
            self.output.label.textAlignment = .right
        }
        
        if let maxWidth = maxWidth {
            availableWidth = maxWidth - (Constants.StackHorizPadding * 2)
            
            // Deviation from the ImGuiRenderer code - If there would be wrapping, put the output below the input
            input.calculateSize()
            output.calculateSize()
            outputOnNewLine = ((input.size.width + output.frame.width) + Constants.StackHorizPadding) > availableWidth
            
            if outputOnNewLine {
                input.calculateSize(maxWidth: availableWidth - Constants.StackHorizPadding)
                output.calculateSize(maxWidth: availableWidth - Constants.StackHorizPadding)
            } else {
                let outputMaxWidth = availableWidth / 2.0 - Constants.StackHorizPadding
                output.calculateSize(maxWidth: outputMaxWidth)
                
                let inputMaxWidth = availableWidth - output.frame.width - Constants.StackHorizPadding
                input.calculateSize(maxWidth: inputMaxWidth)
            }
        } else {
            input.calculateSize()
            output.calculateSize()
            availableWidth = output.frame.width
            outputOnNewLine = false
        }
        
        if outputOnNewLine {
            height = input.size.height + Constants.VerticalPadding + output.frame.height
            output.frame.origin.y += input.size.height + Constants.VerticalPadding
        }
        else {
            height = max(input.size.height, output.frame.height)
            
            // Final positioning
            if input.size.height < height {
                // Move input chunks down
                var diff = height - input.size.height
                if example { diff /= 2.0 }
                
                input.chunks.forEach { $0.frame.origin.y += diff }
            } else {
                // Move output chunk down
                var diff = height - output.frame.height
                if example { diff /= 2.0 }
                
                output.frame.origin.y += diff
            }
        }
        
        for chunk in input.chunks {
            chunk.frame.origin.x += Constants.StackHorizPadding
        }
        
        if example {
            if outputOnNewLine {
                output.frame.origin.x = Constants.StackHorizPadding * 3
            } else {
                output.frame.origin.x = input.chunks.last!.frame.maxX
            }
        } else {
            output.frame.origin.x = availableWidth - output.frame.width + Constants.StackHorizPadding
        }
    }
}
