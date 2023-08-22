//
//  RemindersView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/22/23.
//

import SwiftUI

struct RemindersSettingsView: View {
    @State private var isLoading: Bool = true
    var body: some View {
        List {
            Button(role: .destructive) {
                NotificationManager.shared.removeAllNotifiations()
                DataController.shared.batchDelete(of: "Notification")
            } label: {
                Label("Remove all reminders", systemImage: "trash")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Reminders")
    }
}

#Preview {
    RemindersSettingsView()
}
