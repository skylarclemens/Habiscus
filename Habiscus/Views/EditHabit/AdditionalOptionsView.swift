//
//  AdditionalOptionsView.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/7/23.
//

import SwiftUI

struct AdditionalOptionsView: View {
    @Binding var isCustomCount: Bool
    @Binding var defaultCount: Int16
    
    var body: some View {
        List {
            Section {
                Toggle("Custom count", isOn: $isCustomCount)
            } footer: {
                Text("When enabled, you will be prompted for a value each time progress is logged.")
            }
            Section {
                Stepper("\(defaultCount)", value: $defaultCount, in: 0...32767)
            } header: {
                Text("Default count")
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sets the default count logged when tapping the \"+\" button.")
                    if isCustomCount {
                        Text("Note: ")
                            .fontWeight(.semibold) +
                        Text("Custom count is enabled. Default count will only apply when using widgets or Shortcuts without a count value.")
                    }
                }
            }
        }
        .navigationTitle("Additional options")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        Form {
            AdditionalOptionsView(isCustomCount: .constant(false), defaultCount: .constant(1))
        }
    }
}
