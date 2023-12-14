//
//  DisplayLine.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/14/23.
//

import UIKit


class DisplayLine {
    public let chunks: [DisplayChunk]
    public var size: CGSize = .zero {
        didSet {
            backgroundLayer.frame.size = CGSize(width: size.width + 4.0, height: size.height + 4.0)
        }
    }
    
    public let backgroundLayer = CALayer()
    
    init(chunks: [String]) {
        self.chunks = chunks.map { DisplayChunk(text: $0) }
        backgroundLayer.frame.origin = CGPoint(x: Constants.StackHorizPadding - 2, y: -2)
        backgroundLayer.backgroundColor = UIColor.clear.cgColor
        backgroundLayer.zPosition = -1
        backgroundLayer.name = "StackItemBackgroundLayer"
    }
    
    public func calculateSize(maxWidth: CGFloat = .greatestFiniteMagnitude) {
        size = .zero
        
        // Step 1: Calculate sizes
        
        var availableWidth = maxWidth
        var lineNumber = 0
        
        chunks.forEach({ $0.calculateSize(maxWidth: maxWidth) })
        var lineNumbers = Array(repeating: 0, count: chunks.count)
        
        if maxWidth < .greatestFiniteMagnitude {
            for (chunkIdx, chunk) in chunks.enumerated() {
                // Check for wrap
                let chunkOverflows = chunk.frame.width > availableWidth
                
                let chunkIsShort = chunk.frame.width < 10
                let chunkNotLast = (chunkIdx + 1) < chunks.count
                let shortChunkPlusNextOverflows = (
                    (chunkIsShort && chunkNotLast) &&
                    (chunk.frame.width + chunks[chunkIdx + 1].frame.width) > availableWidth)
                
                if (chunkOverflows || shortChunkPlusNextOverflows) {
                    lineNumber += 1
                    availableWidth = maxWidth
                }
                
                chunk.calculateSize(maxWidth: availableWidth)
                lineNumbers[chunkIdx] = lineNumber
                availableWidth -= chunk.frame.width
            }
        }
        
        // Step 2: Position chunks
        var fromIndex = 0
        
        for lineIndex in 0...lineNumber {
            let toIndex = lineNumbers.firstIndex(where: { $0 > lineIndex }) ?? chunks.count
            let lineChunks = chunks[fromIndex..<toIndex]
            
            let lineSize = lineChunks.reduce(
                CGSize.zero,
                { (acc: CGSize, chunk: DisplayChunk) in
                    return CGSize(
                        width: acc.width + chunk.frame.width,
                        height: max(acc.height, chunk.frame.height))
            })
            
            // Position each chunk in the line
            var chunkStartX = 0.0
            for chunk in lineChunks {
                chunk.frame.origin.x = chunkStartX
                chunk.frame.origin.y = size.height + ((lineSize.height - chunk.frame.height) / 2.0)
                chunkStartX += chunk.frame.width
            }
            
            size.width = max(size.width, lineSize.width)
            size.height += lineSize.height
            
            fromIndex = toIndex
        }
    }
}
