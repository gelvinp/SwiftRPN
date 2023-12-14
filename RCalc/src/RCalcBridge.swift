//
//  RCalcBridge.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 10/31/23.
//

import Foundation
import RCalc


public class SwiftStackItem : Identifiable, Equatable, Hashable {
    public let input: [String]
    public let output: String
    public let outputType: RCalc.`Type`!
    public let accessibilityValue: String
    
    init(_ input: [String] = [], _ output: String = "", _ outputType: RCalc.`Type`! = nil, _ accessibilityValue: String = "") {
        self.input = input
        self.output = output
        self.outputType = outputType
        self.accessibilityValue = accessibilityValue
    }
    
    public static func == (lhs: SwiftStackItem, rhs: SwiftStackItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func appendingInput(_ newInput: String) -> SwiftStackItem {
        var newInputs = self.input
        newInputs.append(newInput)
        return SwiftStackItem(newInputs, self.output, self.outputType, self.accessibilityValue)
    }
    
    func setOutput(_ newOutput: String, _ newOutputType: RCalc.`Type`, _ newAccessibilityValue: String) -> SwiftStackItem {
        return SwiftStackItem(self.input, newOutput, newOutputType, newAccessibilityValue)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(input)
        hasher.combine(output)
    }
}


public protocol RCalcReceiver {
    func display_info(_ info: String)
    func display_error(_ error: String)
    func try_render_command(_ command: String) -> Bool
    func add_stack_item(_ item: SwiftStackItem)
    func remove_stack_item()
    func clear_stack()
}


public class RCalcBridge {
    public static var shared = RCalcBridge()
    
    private var p_app: UnsafeMutablePointer<RCalc.Application>
    private var receiver: RCalcReceiver?
    private var stack_item: SwiftStackItem?
    
    private init() {
        Allocator.setup()
        RCalc.initialize_modules()
        
        let config = RCalc.AppConfig.init()
        var app = RCalc.Application.create(config)
        
        if (!app.__convertToBool()) {
            fatalError("RCalc app creation failed!")
        }
        
        p_app = UnwrapApplicationResult(app)
        
        register_SwiftRPN_commands()
    }
    
    deinit {
        p_app.pointee.cleanup()
        p_app.deallocate()
        Allocator.cleanup()
    }
    
    
    public func set_receiver(receiver recv: RCalcReceiver) {
        receiver = recv
    }
    
    
    public static func display_info(message: String) {
        shared.receiver?.display_info(message)
    }
    
    public static func display_error(error: String) {
        shared.receiver?.display_error(error)
    }
    
    public static func try_render_command(command: String) -> Bool {
        return shared.receiver?.try_render_command(command) ?? false
    }
    
    public static func start_stack_item() {
        shared.stack_item = SwiftStackItem()
    }
    
    public static func append_stack_item(input: String) {
        shared.stack_item = shared.stack_item?.appendingInput(input)
    }
    
    public static func finish_stack_item(output: String, type: UInt8, accessibilityValue: String) {
        shared.stack_item = shared.stack_item?.setOutput(output, RCalcTypeFromUInt8(type), accessibilityValue)
        if let item = shared.stack_item {
            shared.receiver?.add_stack_item(item)
        }
    }
    
    public static func remove_stack_item() {
        shared.receiver?.remove_stack_item()
    }
    
    public static func clear_stack() {
        shared.receiver?.clear_stack()
    }
}
