//
//  SettingsView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/21/23.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        ArchiveView()
                    } label: {
                        Label("Archive", systemImage: "archivebox")
                    }
                }
                Section {
                    NavigationLink {
                        AppearanceView()
                            .navigationTitle("Appearance")
                    } label: {
                        Label("Appearance", systemImage: "paintpalette")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Previewing(\.newHabit) { habit in
            SettingsView()
        }
    }
}
