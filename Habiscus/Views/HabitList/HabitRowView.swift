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
        HabitManager(context: moc, habit: habit)
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
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
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
