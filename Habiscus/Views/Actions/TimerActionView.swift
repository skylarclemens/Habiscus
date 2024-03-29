//
//  TimerView.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/12/23.
//

import SwiftUI

struct TimerActionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var toastManager: ToastManager
    
    @ObservedObject var action: Action
    var moveToNext: (() -> Void)? = nil
    
    @State var showToast: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("\(action.elapsedTime.formattedTime())")
                    .font(.system(size: 42, weight: .medium, design: .rounded))
                    .contentTransition(.numericText())
                HStack(spacing: 24) {
                    Button {
                        action.resetTimer()
                    } label: {
                        Text("Reset")
                            .frame(width: 75, height: 75)
                            .background(
                                Circle().stroke(lineWidth: 1)
                            )
                    }
                    .tint(.secondary)
                    .disabled(!action.isTimerRunning && action.elapsedTime < 1)
                    Button {
                        action.toggleTimer()
                    } label: {
                        Text(action.isTimerRunning ? "Pause" : "Start")
                            .frame(width: 75, height: 75)
                            .background(
                                Circle().stroke(lineWidth: 1)
                            )
                    }
                    .tint(action.isTimerRunning ? .orange : .green)
                }
                Spacer()
                if !action.completed {
                    Button("Mark as complete") {
                        markTimerComplete()
                    }
                    .tint(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemGroupedBackground))
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                if action.isTimerRunning {
                    action.elapsedTime += 1
                }
                if action.elapsedTime >= action.number && !showToast {
                    showToast = true
                }
            }
            .onChange(of: showToast) { _ in
                if showToast {
                    toastManager.successTitle = "Timer has been completed"
                    toastManager.isSuccess = true
                    toastManager.showAlert = true
                    HapticManager.shared.simpleSuccess()
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        checkTimerComplete()
                        dismiss()
                        moveToNext?()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .toast(isPresenting: $toastManager.showAlert) {
            ActionAlertView(isSuccess: $toastManager.isSuccess, successTitle: toastManager.successTitle, errorMessage: toastManager.errorMessage)
        }
    }
    
    func checkTimerComplete() {
        if action.elapsedTime >= action.number {
            markTimerComplete()
        }
    }
    
    func markTimerComplete() {
        action.completed = true
        action.date = Date()
        action.progress?.habit?.lastUpdated = Date()
    }
}

#Preview {
    Previewing(\.timerAction) { action in
        VStack {
            
        }
        .sheet(isPresented: .constant(true)) {
            TimerActionView(action: action)
                .environmentObject(ToastManager())
                .presentationDetents([.fraction(0.5)])
        }
    }
}

extension Double {
    func formattedTime() -> String {
        let interval = Int(self)
        
        let hours = (interval / 3600)
        let minutes = (interval / 60) % 60
        let seconds = interval % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    func formattedTimeText() -> String {
        let interval = Int(self)
        
        let hours = (interval / 3600)
        let minutes = (interval / 60) % 60
        
        if hours > 0 {
            return String(format: "%d hr, %d min", hours, minutes)
        } else {
            return String(format: "%d min", minutes)
        }
    }
}
