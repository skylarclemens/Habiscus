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
                NavigationLink {
                    ArchiveView()
                } label: {
                    Label("Archive", systemImage: "archivebox")
                }
            }
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
