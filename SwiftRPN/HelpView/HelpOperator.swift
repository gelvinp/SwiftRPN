//
//  HelpCommand.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/20/23.
//

import Foundation


struct HelpOperator : Identifiable, Hashable {
    let id = UUID()
    
    let name: String
    let description: String
    let param_count: UInt64
    let allowed_types: [String]
    let examples: [SwiftStackItem]
    
    init(with op: RCalc.Operator) {
        self.name = String(cString: op.name, encoding: .utf8)!
        self.description = String(cString: op.description, encoding: .utf8)!
        self.param_count = op.param_count
        
        var allowed_types: [String] = []
        
        for callIndex in 0..<op.allowed_types.size() {
            let callPrefix = (callIndex == 0) ? "" : "or "
            let callTypes = op.allowed_types[callIndex]
            var callTypeNames: [String] = []
            
            for typeIndex in 0..<callTypes.size() {
                callTypeNames.append(get_type_name(callTypes[typeIndex]) as String)
            }
            
            allowed_types.append("\(callPrefix)\(callTypeNames.joined(separator: ", "))")
        }
        
        self.allowed_types = allowed_types
        
        let preprocessedExamples = preprocess_operator_examples(op)!
        var examples: [SwiftStackItem] = []
        
        for preprocessedExample in preprocessedExamples {
            examples.append(SwiftStackItem(
                preprocessedExample.inputs,
                preprocessedExample.output,
                RCalcTypeFromUInt8(preprocessedExample.type),
                preprocessedExample.accessibiltyValue
            ))
        }
        
        self.examples = examples
    }
}


struct HelpOperatorCategory : Identifiable, Hashable {
    let id = UUID()
    
    let name: String?
    let operators: [HelpOperator]
    
    init(with category: RCalc.OperatorCategory) {
        if let categoryName = category.category_name.pointee {
            self.name = String(cString: categoryName, encoding: .utf8)!
        }
        else {
            self.name = nil
        }
        
        var operators: [HelpOperator] = []
        for operatorIndex in 0..<category.category_ops.size() {
            operators.append(HelpOperator(with: category.category_ops[operatorIndex]!.pointee))
        }
        self.operators = operators
    }
}
