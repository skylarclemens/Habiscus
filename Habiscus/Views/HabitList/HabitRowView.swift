//
//  HabitRow.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/24/23.
//

import SwiftUI

struct HabitRowView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var habit: Habit
    @Binding var date: Date
    
    @EnvironmentObject var toastManager: ToastManager
    
    @State private var showAlert: Bool = false
    @State private var isSuccess: Bool = false
    @State private var successMessage: String = ""
    
    init(habit: Habit, date: Binding<Date>, progress: Progress? = nil) {
        self.habit = habit
        self._date = date
    }
    
    var progress: Progress? {
        if let progress = habit.findProgress(from: date) {
            return progress
        }
        return nil

    }
    
    var isCompleted: Bool {
        if let progress = progress {
            return progress.isCompleted
        }
        return false
    }
    
    var isSkipped: Bool {
        if let progress = progress {
            return progress.isSkipped
        }
        return false
    }
    
    private var habitManager: HabitManager {
        HabitManager(habit: habit)
    }
    
    @State var showActionAlert: Bool = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var alertAction: AlertAction = .archive
    var actionButtonText: String {
        switch alertAction {
        case .archive:
            return "Archive"
        case .delete:
            return "Delete"
        }
    }
    
    enum AlertAction {
        case archive
        case delete
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(habit.habitColor)
                .shadow(color: .black.opacity(isSkipped ? 0 : 0.1), radius: 6, y: 3)
                .shadow(color: habit.habitColor.opacity(isSkipped ? 0 : 0.5), radius: 4, y: 3)
                .padding(.vertical, 2)
            HStack {
                GoalCounterView(habit: habit, date: $date, showIcon: true)
                VStack(alignment: .leading) {
                    Text(habit.wrappedName)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    if habit.icon != nil {
                        Text("\(progress?.totalCount ?? 0) / \(habit.goalNumber) \(habit.wrappedUnit)")
                            .font(.system(.callout, design: .rounded))
                            .bold()
                            .foregroundColor(.white.opacity(0.75))
                    }
                }
                Spacer()
                if !habit.isArchived {
                    AddCountView(habit: habit, progress: progress, date: $date, habitManager: habitManager)
                }
            }
            .padding()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
        .opacity(isCompleted || isSkipped ? 0.5 : 1)
        .contextMenu {
            Group {
                if !habit.isArchived {
                    if let progress = progress,
                       !progress.isEmpty {
                        Button {
                            habitManager.undoLastCount(from: date)
                        } label: {
                            Label("Undo last count", systemImage: "arrow.uturn.backward")
                        }
                    }
                    if !isSkipped {
                        Button {
                            if let progress = progress {
                                habitManager.setProgressSkip(progress: progress, skip: true)
                            } else {
                                habitManager.addNewSkippedProgress(date: date)
                            }
                        } label: {
                            Label("Skip", systemImage: "forward.end")
                        }
                    } else {
                        Button {
                            if let progress = progress {
                                habitManager.setProgressSkip(progress: progress, skip: false)
                            }
                        } label: {
                            Label("Undo skip", systemImage: "backward.end")
                        }
                    }
                    Button {
                        self.alertTitle = "Archive \(habit.wrappedName)"
                        self.alertMessage = "Are you sure you want to archive this habit?"
                        self.alertAction = .archive
                        showActionAlert = true
                    } label: {
                        Label("Archive", systemImage: "archivebox")
                    }
                } else {
                    Button {
                        withAnimation {
                            do {
                                toastManager.successTitle = "\(habit.wrappedName) has been restored"
                                try habitManager.unarchiveHabit()
                                toastManager.isSuccess = true
                                toastManager.showAlert = true
                                HapticManager.shared.simpleSuccess()
                            } catch let error {
                                print(error.localizedDescription)
                                toastManager.errorMessage = "Error while restoring"
                                toastManager.isSuccess = false
                                toastManager.showAlert = true
                                HapticManager.shared.simpleError()
                            }
                        }
                    } label: {
                        Label("Restore from archive", systemImage: "arrow.uturn.backward")
                    }
                }
                Button(role: .destructive) {
                    self.alertTitle = "Delete \(habit.wrappedName)"
                    self.alertMessage = "Are you sure you want to permanently delete \(habit.wrappedName)?\n\nAll data associated with this habit will be deleted. You cannot undo this action."
                    self.alertAction = .delete
                    showActionAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .alert(self.alertTitle, isPresented: $showActionAlert) {
            Button(actionButtonText, role: .destructive) {
                Task {
                    switch alertAction {
                    case .archive:
                        withAnimation {
                            do {
                                try habitManager.archiveHabit()
                                toastManager.successTitle = "\(habit.wrappedName) has been archived"
                                toastManager.isSuccess = true
                                toastManager.showAlert = true
                                HapticManager.shared.simpleSuccess()
                            } catch let error {
                                print(error.localizedDescription)
                                toastManager.errorMessage = "Error while archiving"
                                toastManager.isSuccess = false
                                toastManager.showAlert = true
                                HapticManager.shared.simpleError()
                            }
                        }
                    case .delete:
                        withAnimation {
                            do {
                                toastManager.successTitle = "\(habit.wrappedName) has been deleted"
                                try habitManager.removeHabit()
                                toastManager.isSuccess = true
                                toastManager.showAlert = true
                                HapticManager.shared.simpleSuccess()
                            } catch let error {
                                print(error.localizedDescription)
                                toastManager.errorMessage = "Error while deleting"
                                toastManager.isSuccess = false
                                toastManager.showAlert = true
                                HapticManager.shared.simpleError()
                            }
                        }
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(self.alertMessage)
        }
    }
}

struct HabitRowView_Previews: PreviewProvider {
    static var previews: some View {
        Previewing(\.habit) { habit in
            List {
                HabitRowView(habit: habit, date: .constant(Date()))
            }.listStyle(.grouped)
        }
    }
}
