//
//  MainHelpView.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/20/23.
//

import SwiftUI

struct MainHelpView: View {
    var SwiftRPNVersion: String {
        "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "Unknown")"
    }
    
    var RCalcVersion: String {
        "Built using RCalc version \(GetVersionString() as String)"
    }
    
    var HelpText: String {
        String(cString: RCalc.HelpText.program_info, encoding: .utf8)!
            .replacingOccurrences(of: "RCalc", with: "SwiftRPN")
            .replacingOccurrences(of: "window", with: "page")
    }
    
    var HelpSections: [HelpSection] {
        var sections: [HelpSection] = []
        let source = SwiftRPNHelpSections().pointee
        sections.reserveCapacity(source.size())
        for index in 0..<source.size() {
            sections.append(HelpSection(with: source[index]))
        }
        return sections
    }
    
    var HelpCommands: [HelpCommand] {
        var commands: [HelpCommand] = []
        let source = RCalc._GlobalCommandMap.get_alphabetical().pointee
        commands.reserveCapacity(source.size())
        for index in 0..<source.size() {
            commands.append(HelpCommand(with: source[index]!.pointee))
        }
        return commands
    }
    
    var HelpOperatorCategories: [HelpOperatorCategory] {
        let operatorMap = RCalc.OperatorMap.get_operator_map().pointee
        let operatorCategories = operatorMap.get_alphabetical()
        
        var categories: [HelpOperatorCategory] = []
        categories.reserveCapacity(operatorCategories.size())
        
        for index in 0..<operatorCategories.size() {
            categories.append(HelpOperatorCategory(with: operatorCategories[index]!.pointee))
        }
        
        return categories
    }
    
    var HelpUnitFamilies: [HelpUnitFamily] {
        let unitsMap = RCalc.UnitsMap.get_units_map().pointee
        let unitFamilies = unitsMap.get_alphabetical()
        
        var families: [HelpUnitFamily] = []
        families.reserveCapacity(unitFamilies.size())
        
        for index in 0..<unitFamilies.size() {
            families.append(HelpUnitFamily(with: unitFamilies[index]!.pointee))
        }
        
        return families
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("SwiftRPN")
                    .font(.title)
                
                Spacer(height: 8)
                
                Text(SwiftRPNVersion)
                    .font(.caption)
                
                Text(RCalcVersion)
                    .font(.caption)
                
                Spacer(height: 16)
                
               Text(HelpText)
                
                ForEach(HelpSections) { section in
                    Spacer(height: 8)
                    
                    HelpSectionView(section)
                }
                
                Divider()
                    .padding(.top, 8)
                    .padding(.bottom, 24)
//                
                Text("Commands")
                    .font(.title2)
                
                ForEach(HelpCommands) { command in
                    Spacer(height: 16)
                    
                    HelpCommandView(command)
                }
                
                Divider()
                    .padding(.top, 24)
                    .padding(.bottom, 24)
//                
                Text("Operators")
                    .font(.title2)
                
                ForEach(HelpOperatorCategories) { category in
                    HelpOperatorCategoryView(category)
                }
                
                Divider()
                    .padding(.bottom, 24)
                
                Text("Unit Families")
                    .font(.title2)
                
                ForEach(HelpUnitFamilies) { family in
                    Spacer(height: 16)
                    
                    HelpUnitFamilyView(family)
                }
                
                Divider()
                    .padding(.top, 24)
                    .padding(.bottom, 24)
//
                Text("Licenses")
                    .font(.title2)
                
                Spacer(height: 16)
                
                Text(GetLicenseInfo())
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func HelpSectionView(_ section: HelpSection) -> some View {
        VStack(alignment: .leading) {
            Text(section.header)
                .font(.title3)
            Text(section.text)
        }
    }
    
    private func HelpCommandView(_ command: HelpCommand) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(command.name)
                    .foregroundStyle(.rcalcBlue)
                
                if let aliases = command.aliases {
                    Text(aliases)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text(command.description)
        }
    }
    
    private func HelpOperatorCategoryView(_ category: HelpOperatorCategory) -> some View {
        VStack(alignment: .leading) {
            if let name = category.name {
                Text("\(name) Operators")
                    .font(.title3)
            }
            
            ForEach(category.operators) { op in
                Spacer(height: 16)
                
                HelpOperatorView(op)
            }
            
            Spacer(height: 32)
        }
    }
    
    private func HelpOperatorView(_ op: HelpOperator) -> some View {
        VStack(alignment: .leading) {
            Text(op.name)
                .foregroundStyle(.rcalcGreen)
            
            Text(op.description)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
            
            if op.param_count > 0 {
                DisclosureGroup {
                    VStack(alignment: .leading) {
                        ForEach(op.allowed_types, id: \.self) { types in
                            HStack(alignment: .center) {
                                Spacer(width: 32)
                                
                                Text(types)
                                
                                SwiftUI.Spacer()
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                } label: {
                    Text("Accepts \(op.param_count) argument\(op.param_count == 1 ? "" : "s")")
                        .foregroundStyle(.secondary)
                }
                .disclosureGroupStyle(HelpDisclosureStyle())
            }
            
            if op.examples.count > 0 {
                DisclosureGroup {
                    HStack {
                        Spacer(width: 32)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(op.examples) { example in
                                HelpExampleView(stackItem: example)
                                    .padding(.vertical, 8)
                                
                                if example != op.examples.last {
                                    Divider()
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .foregroundStyle(.quaternary)
                        }
                    }
                } label: {
                    Text("Examples")
                        .foregroundStyle(.secondary)
                }
                .disclosureGroupStyle(HelpDisclosureStyle())
            }
        }
    }
    
    private func HelpUnitFamilyView(_ family: HelpUnitFamily) -> some View {
        VStack(alignment: .leading) {
            Text(family.name)
                .foregroundStyle(.rcalcUnitLabel)
            
            Text(family.baseType)
                .foregroundStyle(.primary)
            
            DisclosureGroup {
                VStack(alignment: .leading) {
                    ForEach(family.units) { unit in
                        HStack(alignment: .center) {
                            Spacer(width: 32)
                            
                            Image(systemName: "circle.fill")
                                .font(.system(size: 8))
                            
                            Text(unit.name)
                            
                            Text("[Usage: \(unit.usage)]")
                            
                            SwiftUI.Spacer()
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            } label: {
                Text("\(family.units.count) unit\(family.units.count == 1 ? "" : "s")")
                    .foregroundStyle(.secondary)
            }
            .disclosureGroupStyle(HelpDisclosureStyle())
        }
    }
    
    private func Spacer(height: CGFloat) -> some View {
        SwiftUI.Spacer()
            .frame(height: height)
    }
    
    private func Spacer(width: CGFloat) -> some View {
        SwiftUI.Spacer()
            .frame(width: width)
    }
}

#Preview {
    NavigationStack {
        MainHelpView()
    }
}
