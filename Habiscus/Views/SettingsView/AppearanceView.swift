//
//  AppearanceView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/22/23.
//

import SwiftUI

struct AppearanceView: View {
    @AppStorage("selectedAppearance") var selectedAppearance: DisplayMode = .system
    
    var body: some View {
        Form {
            Picker("Appearance", selection: $selectedAppearance) {
                Text("System").tag(DisplayMode.system)
                Text("Light").tag(DisplayMode.light)
                Text("Dark").tag(DisplayMode.dark)
            }.pickerStyle(.inline)
                .labelsHidden()
        }
    }
}

#Preview {
    AppearanceView()
}
