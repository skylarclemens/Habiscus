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
    
    var body: some View {
        Section {
            Toggle(isOn: $setReminders.animation()) {
                Label {
                    Text("Set reminder")
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
        }
    }
}

struct RemindersView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            RemindersView(setReminders: .constant(true), selectedTime: .constant(Date()))
        }
    }
}
