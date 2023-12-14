//
//  HelpDisclosureStyle.swift
//  SwiftRPN
//
//  Created by Patrick Gelvin on 11/22/23.
//

import SwiftUI

struct HelpDisclosureStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Button {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "arrowtriangle.right.fill")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .rotationEffect(configuration.isExpanded ? .degrees(90) : .zero)
                        .animation(.easeOut, value: configuration.isExpanded)
                    
                    configuration.label
                    
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if configuration.isExpanded {
                configuration.content
            }
        }
    }
}


#Preview {
    DisclosureGroup {
        Text("Disclosed!")
    } label: {
        Text("Disclosure Group")
    }
    .disclosureGroupStyle(HelpDisclosureStyle())
}
