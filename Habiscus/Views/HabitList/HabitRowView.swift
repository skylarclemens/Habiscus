//
//  HabitRow.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/24/23.
//

import SwiftUI

struct HabitRowView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject private var hapticManager: HapticManager
    @ObservedObject var habit: Habit
    var progress: Progress?
    @State private var animated: Bool = false
    @Binding var date: Date
    
    init(habit: Habit, date: Binding<Date>, progress: Progress? = nil) {
        self.habit = habit
        self._date = date
        self.progress = progress
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
    
    var isProgressEmpty: Bool {
        if let progress = progress {
            return progress.countsArray.isEmpty
        }
        return true
    }
    
    private var habitManager: HabitManager {
        HabitManager(context: moc, habit: habit)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(habit.habitColor)
                .shadow(color: .black.opacity(isCompleted || isSkipped ? 0 : 0.1), radius: 6, y: 3)
                .shadow(color: habit.habitColor.opacity(isCompleted || isSkipped ? 0 : 0.5), radius: 4, y: 3)
                .padding(.vertical, 2)
            HStack {
                GoalCounterView(habit: habit, date: $date, showIcon: true)
                VStack(alignment: .leading) {
                    Text(habit.wrappedName)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    if habit.icon != nil {
                        Text("\(progress?.totalCount ?? 0) / \(habit.goalNumber) \(habit.goalMetric)")
                            .font(.system(.callout, design: .rounded))
                            .foregroundColor(.white.opacity(0.75))
                    }
                }
                Spacer()
                AddCountView(habit: habit, progress: progress, date: $date)
            }
            .padding()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
        .opacity(isCompleted || isSkipped ? 0.5 : 1)
        .opacity(animated ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 1.5, dampingFraction: 1.5)) {
                animated = true
            }
            if let progress = progress {
                print("\(habit.wrappedName): \(progress.totalCount)")
            }
        }
        .contextMenu {
            Group {
                if !isProgressEmpty {
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
                    habitManager.archiveHabit()
                } label: {
                    Label("Archive", systemImage: "archivebox")
                }
                Button(role: .destructive) {
                    habitManager.removeHabit()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

struct HabitRowView_Previews: PreviewProvider {
    static var dataController = DataController()
    static var moc = dataController.container.viewContext
    static var previews: some View {
        let habit = Habit(context: moc)
        let count = Count(context: moc)
        let progress = Progress(context: moc)
        progress.date = Date.now
        progress.isCompleted = false
        count.createdAt = Date.now
        count.progress = progress
        habit.name = "Test"
        habit.icon = "🤩"
        habit.createdAt = Date.now
        progress.addToCounts(count)
        habit.addToProgress(progress)
        habit.goal = 1
        habit.goalFrequency = 1
        return List {
            HabitRowView(habit: habit, date: .constant(Date()), progress: progress)
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        
                    }
                }
            HabitRowView(habit: habit, date: .constant(Date()))
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        
                    }
                }
        }
        .listStyle(.grouped)
    }
}
