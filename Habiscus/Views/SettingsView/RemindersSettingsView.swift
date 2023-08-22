//
//  RemindersView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/22/23.
//

import SwiftUI

struct RemindersSettingsView: View {
    @State private var showAlert: Bool = false
    @State private var isSuccess: Bool = true
    var body: some View {
        List {
            Button(role: .destructive) {
                withAnimation {
                    do {
                        try DataController.shared.batchDelete(of: "Notification")
                        NotificationManager.shared.removeAllNotifiations()
                        isSuccess = true
                        showAlert = true
                        HapticManager.shared.simpleSuccess()
                    } catch let error {
                        print(error.localizedDescription)
                        isSuccess = false
                        showAlert = true
                        HapticManager.shared.simpleError()
                    }
                }
            } label: {
                Label("Remove all reminders", systemImage: "trash")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Reminders")
        .toast(isPresenting: $showAlert) {
            ActionAlertView(isSuccess: $isSuccess, successTitle: "Reminders deleted", errorMessage: "Error while deleting")
        }
    }
}

#Preview {
    RemindersSettingsView()
}
