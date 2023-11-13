//
//  SettingsView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/21/23.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section {
                NavigationLink {
                    AppearanceView()
                } label: {
                    Label("Appearance", systemImage: "paintpalette")
                }
                NavigationLink {
                    ArchiveView()
                } label: {
                    Label("Archive", systemImage: "archivebox")
                }
                NavigationLink {
                    RemindersSettingsView()
                } label: {
                    Label("Reminders", systemImage: "bell")
                }
                
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Previewing(\.newHabit) { habit in
            NavigationStack {
                SettingsView()
            }
        }
    }
}
