//
//  RemindersView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/17/23.
//

import SwiftUI
import UserNotifications

struct RemindersView: View {
    @Binding var setReminders: Bool
    @Binding var selectedTime: Date
    @Binding var notifications: [Notification]
    
    var body: some View {
        Section {
            Toggle(isOn: $setReminders.animation()) {
                Label {
                    Text("Set reminders")
                } icon: {
                    Image(systemName: "bell.fill")
                }
            }.tint(.none)
                .onChange(of: setReminders) { newValue in
                    if newValue {
                        NotificationManager.shared.registerLocal()
                    }
                }
            if setReminders {
                DatePicker("What time?", selection: $selectedTime, displayedComponents: .hourAndMinute)
            }
        } footer: {
            if setReminders {
                Text("Reminders will be set at the selected time for each day your habit repeats")
            }
        }
    }
}

struct RemindersView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            RemindersView(setReminders: .constant(true), selectedTime: .constant(Date()), notifications: .constant([]))
        }
    }
}
