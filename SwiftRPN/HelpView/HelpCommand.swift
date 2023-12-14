//
//  HelpCommand.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/20/23.
//

import Foundation


struct HelpCommand : Identifiable, Hashable {
    let id = UUID()
    
    let name: String
    let description: String
    let aliases: String?
    
    init(with command: RCalc.CommandMeta) {
        self.name = String(cString: command.name, encoding: .utf8)!
        self.description = String(cString: command.description, encoding: .utf8)!
        
        let alias_strings = command.aliases.map { alias in
            String(cString: alias!, encoding: .utf8)!
        }
        
        if alias_strings.isEmpty {
            self.aliases = nil
        }
        else {
            self.aliases = "aliases: [\(alias_strings.joined(separator: ", "))]"
        }
    }
}
