//
//  Settings.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/26/23.
//

import Foundation

class Settings {
    static let shared = Settings()
    
    enum ColorTheme : Int {
        case Standard
        case Queer
    }
    
    public var colorTheme: ColorTheme {
        get {
            ColorTheme(rawValue: UserDefaults.standard.integer(forKey: name(for: \.colorTheme))) ?? .Standard
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: name(for: \.colorTheme))
            
            if let subscriptions = subscriptions[\SettingsNames.colorTheme] {
                for subscription in subscriptions {
                    subscription()
                }
            }
        }
    }
    
    public var extraCols: Int {
        get {
            min(max(UserDefaults.standard.integer(forKey: name(for: \.extraCols)), 0), 1)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: name(for: \.extraCols))
            
            if let subscriptions = subscriptions[\SettingsNames.extraCols] {
                for subscription in subscriptions {
                    subscription()
                }
            }
        }
    }
    
    public var extraButtonData: [[ExtraButtonAssignment?]] {
        get {
            let maxCols = extraCols
            let defaultRow: [ExtraButtonAssignment?] = Array(repeating: nil, count: maxCols)
            let defaultData = Array(repeating: defaultRow, count: 4)
            
            guard let rawJSON = UserDefaults.standard.data(forKey: name(for: \.extraButtonData)) else {
                return defaultData
            }
            
            let decoder = JSONDecoder()
            guard let rawRows = try? decoder.decode([[ExtraButtonAssignment?]].self, from: rawJSON) else {
                return defaultData
            }
            
            var rows = defaultData
            
            for rowIndex in 0..<4 {
                for colIndex in 0..<maxCols {
                    rows[rowIndex][colIndex] = rawRows[rowIndex][colIndex]
                }
            }
            
            return rows
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: name(for: \.extraButtonData))
            }
            
            if let subscriptions = subscriptions[\SettingsNames.extraButtonData] {
                for subscription in subscriptions {
                    subscription()
                }
            }
        }
    }
    
    public func subscribe(to keyPath: KeyPath<SettingsNames, String>, action: @escaping ()->()) {
        if subscriptions[keyPath] == nil {
            subscriptions[keyPath] = []
        }
        
        subscriptions[keyPath]?.append(action)
    }
    
    private var subscriptions: [KeyPath<SettingsNames, String>: [()->()]] = [:]
    
    private init() {}
    
    struct SettingsNames {
        static let shared = SettingsNames()
        
        let colorTheme = "colorTheme"
        let extraCols = "extraCols"
        let extraButtonData = "extraButtonData"
        
        private init() {}
    }
    
    private func name(for keyPath: KeyPath<SettingsNames, String>) -> String {
        return SettingsNames.shared[keyPath: keyPath]
    }
}
