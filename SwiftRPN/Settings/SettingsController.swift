//
//  OptionsView.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/23/23.
//

import SwiftUI

struct SettingsController: View {
    @State private var extraCols = Settings.shared.extraCols
    @State private var colorTheme = Settings.shared.colorTheme
    
    var body: some View {
        Form {
            Section(footer: Text("Add additional customizable buttons to the keyboard in landscape mode. Long press to assign a value.")) {
                Picker("Extra Button Columns", selection: $extraCols) {
                    Text("None").tag(0)
                    Text("1 Column").tag(1)
                }
                .onChange(of: extraCols) { newValue in
                    Settings.shared.extraCols = newValue
                }
            }
            
            Section(footer: Text("Change the default color for items on the stack")) {
                Picker("Default Color Theme", selection: $colorTheme) {
                    Text("Standard").tag(Settings.ColorTheme.Standard)
                    Text("Queer").tag(Settings.ColorTheme.Queer)
                }
                .onChange(of: colorTheme) { newValue in
                    Settings.shared.colorTheme = newValue
                }
            }
        }
        .navigationTitle("Settings")
    }
}
