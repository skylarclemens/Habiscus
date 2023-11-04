//
//  HabitView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/23/23.
//

import SwiftUI
import Charts

struct HabitView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var toastManager: ToastManager
    @ObservedObject var habit: Habit
    @Binding var date: Date
    @State private var updateHabit: DataOperation<Habit>?
    
    private var progress: Progress? {
        return habit.findProgress(from: date)
    }
    
    private var habitManager: HabitManager {
        HabitManager(habit: habit)
    }
    
    private var showEntries: Bool {
        if let progress = progress {
            return progress.countsArray.count > 0
        }
        return false
    }
    
    private var isSkipped: Bool {
        if let progress = progress {
            return progress.isSkipped
        }
        return false
    }
    
    @State private var showSkippedOverlay: Bool = false
    
    var body: some View {
        if habit.isDeleted {
            Text("Sorry, habit has been deleted!")
        } else {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color(UIColor.secondarySystemBackground))
                    .ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(habit.habitColor)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, y: 8)
                            .shadow(color: habit.habitColor.opacity(0.3), radius: 10, y: 8)
                        VStack(alignment: .leading) {
                            HStack {
                                GoalCounterView(habit: habit, size: 60, date: $date, showIcon: true)
                                VStack(alignment: .leading) {
                                    Text(habit.wrappedName)
                                        .font(.system(size: 38, design: .rounded))
                                        .bold()
                                        .foregroundColor(.white)
                                        .minimumScaleFactor(0.5)
                                        .padding(.trailing)
                                        .lineLimit(2)
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
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    }
                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 24, style: .continuous))
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
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    StatisticsView(habit: habit)
                        .padding()
                    
                    VStack {
                        CalendarView(habit: habit, date: $date, size: 40, color: habit.habitColor)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.regularMaterial)
                                    .shadow(color: Color.black.opacity(0.1), radius: 12, y: 8)
                            )
                            .padding(.horizontal)
                    }
                    
                    VStack {
                        CountGridView(habit: habit, size: 14, spacing: 4)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.regularMaterial)
                                    .shadow(color: Color.black.opacity(0.1), radius: 12, y: 8)
                            )
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        if showEntries {
                            VStack(alignment: .leading) {
                                Section {
                                    ForEach(progress?.countsArray ?? []) { count in
                                        HStack(spacing: 12) {
                                            Text("+1")
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                        .fill(habit.habitColor.opacity(0.8))
                                                        .shadow(color: habit.habitColor.opacity(0.3), radius: 4, y: 2)
                                                )
                                            Text(count.dateString)
                                        }
                                    }
                                } header: {
                                    Text("Entries")
                                        .font(.headline)
                                        .padding(.bottom, 4)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.regularMaterial)
                                    .shadow(color: Color.black.opacity(0.1), radius: 12, y: 8)
                            )
                            .padding()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                        }
                    }
                    .opacity(showEntries ? 1 : 0)
                    .animation(.spring(), value: showEntries)
                    if let startDate = habit.startDate {
                        Text("Start date: \(startDate.formatted(date: .abbreviated, time: .omitted))")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                }
                .toolbar {
                    ToolbarItem {
                        Menu {
                            if !habit.isArchived {
                                Button {
                                    updateHabit = DataOperation(withExistsingData: habit, in: moc)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                Button {
                                    withAnimation {
                                        do {
                                            try habitManager.archiveHabit()
                                            toastManager.successTitle = "\(habit.wrappedName) has been archived"
                                            toastManager.isSuccess = true
                                            toastManager.showAlert = true
                                            HapticManager.shared.simpleSuccess()
                                            dismiss()
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
                                    dismiss()
                                } label: {
                                    Label("Delete", systemImage: "trash")
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
                                    dismiss()
                                } label: {
                                    Label("Restore from archive", systemImage: "arrow.uturn.backward")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }
                .sheet(item: $updateHabit) { update in
                    NavigationStack {
                        EditHabitView(habit: update.childObject)
                            .navigationTitle("Edit habit")
                    }
                    .environment(\.managedObjectContext, update.childContext)
                }
            }
        }
    }
}

struct HabitView_Previews: PreviewProvider {
    static var previews: some View {
        Previewing(\.habit) { habit in
            NavigationStack {
                HabitView(habit: habit, date: .constant(Date()))
                    .navigationTitle(habit.wrappedName)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
