//
//  HelpCommand.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/20/23.
//

import Foundation


struct HelpUnit : Identifiable, Hashable {
    let id = UUID()
    
    let name: String
    let usage: String
    
    init(with unit: RCalc.Unit) {
        self.name = String(cString: unit.p_name, encoding: .utf8)!
        self.usage = String(cString: unit.p_usage, encoding: .utf8)!
    }
}


struct HelpUnitFamily : Identifiable, Hashable {
    let id = UUID()
    
    let name: String
    let baseType: String
    let units: [HelpUnit]
    
    init(with family: RCalc.UnitFamily) {
        self.name = String(cString: family.p_name, encoding: .utf8)!
        self.baseType = "Base type: \(get_type_name(family.base_type) as String)"
        
        var units: [HelpUnit] = []
        for unitIndex in 0..<family.units.size() {
            units.append(HelpUnit(with: family.units[unitIndex]!.pointee))
        }
        
        self.units = units
    }
}
