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
    @State private var showAddCountAlert: Bool = false
    
    private var progress: Progress? {
        return habit.findProgress(from: date)
    }
    
    private var progressActions: [Action]? {
        progress?.actionsArray
    }
    
    private var habitManager: HabitManager {
        HabitManager(habit: habit)
    }
    
    private var showEntries: Bool {
        if let progress = progress {
            if habit.wrappedProgressMethod == .counts {
                return progress.countsArray.count > 0
            } else {
                return progress.completedActionsArray.count > 0
            }
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
    @State private var viewAction: Action?
    
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
                                        .font(.system(size: 38, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .minimumScaleFactor(0.5)
                                        .padding(.trailing, 8)
                                        .lineLimit(1)
                                    Text("\(progress?.totalCount ?? 0) / \(habit.goalNumber) \(habit.wrappedProgressMethod == .counts ? habit.wrappedUnit : "completed")")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.75))
                                }
                                Spacer()
                                if !habit.isArchived {
                                    if habit.wrappedProgressMethod == .counts {
                                        AddCountView(habit: habit, progress: progress, date: $date, habitManager: habitManager, showAddCountAlert: $showAddCountAlert)
                                    } else {
                                        StartActionsView(habit: habit, progress: progress, date: $date, habitManager: habitManager)
                                    }
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
                                Button {
                                    showAddCountAlert = true
                                } label: {
                                    Label("Add custom count", systemImage: "plus")
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
                    .frame(maxWidth: 500)
                    if habit.wrappedProgressMethod == .actions && !habit.actionsArray.isEmpty {
                        VStack(spacing: 16) {
                            ForEach(habit.actionsArray) { action in
                                HStack {
                                    Image(systemName: action.actionType.symbol())
                                        .font(.system(size: 20))
                                        .foregroundStyle(.secondary)
                                    Text(action.actionType.label())
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    if action.actionType == .timer {
                                        Text(action.number.formattedTimeText())
                                            .font(.subheadline)
                                            .foregroundStyle(.primary.opacity(0.75))
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 2)
                                            .background(.ultraThinMaterial)
                                            .clipShape(.rect(cornerRadius: 6))
                                    }
                                    Spacer()
                                    if let progressAction = progressActions?.first(where: { $0.order == action.order }) {
                                        if (action.actionType == .emotion || action.actionType == .note) && progressAction.completed {
                                            Button {
                                                viewAction = progressAction
                                            } label: {
                                                Text("View")
                                                    .font(.callout)
                                            }
                                            .foregroundStyle(.secondary)
                                            .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                                            .background(.secondary.opacity(0.25))
                                            .clipShape(Capsule())
                                            .overlay(
                                                Capsule().stroke(.secondary.opacity(0.5), lineWidth: 1)
                                            )
                                        }
                                        Image(systemName: "\(progressAction.completed ? "checkmark.circle.fill" : "circle")")
                                            .foregroundStyle(progressAction.completed ? Color.green : Color.secondary)
                                            
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(10)
                        .frame(maxWidth: 500, alignment: .leading)
                        .background(.regularMaterial)
                        .clipShape(.rect(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.secondary.opacity(0.15), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    
                    VStack(alignment: .center, spacing: 16) {
                        StatisticsView(habit: habit)
                            .padding(.horizontal)
                        CalendarView(habit: habit, date: $date, size: 40, color: habit.habitColor)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.regularMaterial)
                                    .shadow(color: Color.black.opacity(0.1), radius: 12, y: 8)
                            )
                            .padding(.horizontal)
                            
                        CountGridView(habit: habit, size: 14, spacing: 4)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.regularMaterial)
                                    .shadow(color: Color.black.opacity(0.1), radius: 12, y: 8)
                            )
                            .padding(.horizontal)
                            .frame(maxWidth: 500)
                        if showEntries {
                            VStack(alignment: .leading) {
                                Section {
                                    if habit.wrappedProgressMethod == .counts {
                                        ForEach(progress?.countsArray ?? []) { count in
                                            HStack(spacing: 8) {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundStyle(.white, habit.habitColor)
                                                Group {
                                                    Text("^[\(count.amount) \(habit.wrappedUnit)](inflect: true)")
                                                        .fontWeight(.medium) +
                                                    Text(" added")
                                                }.font(.system(size: 14))
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 8))
                                            .background(
                                                Capsule()
                                                    .fill(.secondary.opacity(0.1))
                                            )
                                            Text(count.wrappedCreatedDate.formatted(date: .abbreviated, time: .shortened))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .padding(.leading, 36)
                                        }
                                    } else if let completedActions = progress?.completedActionsArray {
                                        ForEach(completedActions) { action in
                                            HStack(spacing: 8) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundStyle(.white, habit.habitColor)
                                                Group {
                                                    Text("\(action.actionTypeString)")
                                                        .fontWeight(.medium) +
                                                    Text(" completed")
                                                }.font(.system(size: 14))
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 8))
                                            .background(
                                                Capsule()
                                                    .fill(.secondary.opacity(0.1))
                                            )
                                            Text(action.wrappedDate.formatted(date: .abbreviated, time: .shortened))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .padding(.leading, 36)
                                        }
                                    }
                                } header: {
                                    Text("History")
                                        .font(.headline)
                                        .padding(.bottom, 4)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.regularMaterial)
                                    .shadow(color: Color.black.opacity(0.1), radius: 12, y: 8)
                            )
                            .padding(.horizontal)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                            .frame(maxWidth: 500, alignment: .leading)
                            .opacity(showEntries ? 1 : 0)
                            .animation(.spring(), value: showEntries)
                        }
                        if let startDate = habit.startDate {
                            Text("Start date: \(startDate.formatted(date: .abbreviated, time: .omitted))")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top)
                    .frame(maxWidth: 500)
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
                                    dismiss()
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
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }
                .sheet(item: $viewAction, onDismiss: { viewAction = nil }) { action in
                    ActionView(action: action)
                }
                .sheet(item: $updateHabit) { update in
                    NavigationStack {
                        EditHabitView(habit: update.childObject)
                            .navigationTitle("Edit habit")
                    }
                    .environment(\.managedObjectContext, update.childContext)
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
                                dismiss()
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text(self.alertMessage)
                }
            }
        }
    }
}

struct HabitView_Previews: PreviewProvider {
    static var previews: some View {
        Previewing(\.habitWithActions) { habit in
            NavigationStack {
                HabitView(habit: habit, date: .constant(Date()))
                    .navigationTitle(habit.wrappedName)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
