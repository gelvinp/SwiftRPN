//
//  HelpSection.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/20/23.
//

import Foundation


struct HelpSection : Identifiable, Hashable {
    let id = UUID()
    
    let header: String
    let text: String
    
    init(with section: RCalc.HelpText.HelpSection) {
        self.header = String(cString: section.header, encoding: .utf8)!
        self.text = String(cString: section.text, encoding: .utf8)!
            .replacingOccurrences(of: "<enter>", with: "⏎")
            .replacingOccurrences(of: "RCalc", with: "SwiftRPN")
    }
}
