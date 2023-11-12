//
//  TimerView.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/12/23.
//

import SwiftUI

struct TimerActionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var action: Action
    var moveToNext: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Timer action view")
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        markTimerComplete()
                        dismiss()
                        moveToNext()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func markTimerComplete() {
        action.completed = true
        action.date = Date()
        action.progress?.habit?.lastUpdated = Date()
    }
}

#Preview {
    var emptyFunction : () -> Void = { }
    return TimerActionView(action: Action(), moveToNext: emptyFunction)
}
