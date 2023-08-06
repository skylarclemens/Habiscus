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
    @ObservedObject var progress: Progress
    @State private var animated: Bool = false
    @Binding var date: Date
    
    init(habit: Habit, date: Binding<Date>, progress: Progress? = nil) {
        self.habit = habit
        self._date = date
        self.progress = progress ?? Progress.None
    }
    
    var isCompleted: Bool {
        progress != Progress.None ? progress.isCompleted : false
    }
    
    var isProgressEmpty: Bool {
        progress != Progress.None ? progress.countsArray.isEmpty : true
    }
    
    private var habitManager: HabitManager {
        HabitManager(context: moc, habit: habit)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(habit.habitColor)
                .shadow(color: .black.opacity(isCompleted ? 0 : 0.1), radius: 6, y: 3)
                .shadow(color: habit.habitColor.opacity(isCompleted ? 0 : 0.5), radius: 4, y: 3)
                .padding(.vertical, 2)
            HStack {
                GoalCounterView(habit: habit, date: $date)
                Text(habit.wrappedName)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                Spacer()
                Button {
                    var wasProgressJustCompleted = false
                    
                    if self.progress != Progress.None {
                        wasProgressJustCompleted = habitManager.addNewCount(progress: progress, date: date, habit: habit)
                    } else {
                        wasProgressJustCompleted = habitManager.addNewProgress(date: date)
                    }
                    
                    if wasProgressJustCompleted {
                        HapticManager.instance.completionSuccess()
                        SoundManager.instance.playCompleteSound(sound: .complete)
                    } else {
                        simpleSuccess()
                    }
                } label: {
                    Image(systemName: "plus")
                        .bold()
                        .foregroundColor(.white)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white.opacity(0.25))
                )
                .buttonStyle(.plain)
            }
            .padding()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
        .opacity(isCompleted ? 0.5 : 1)
        .opacity(animated ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 1.5, dampingFraction: 1.5)) {
                animated = true
            }
        }
        .contextMenu {
            Group {
                Button {
                    habitManager.undoLastCount(from: date)
                } label: {
                    Label("Undo last count", systemImage: "arrow.uturn.backward")
                        .foregroundColor(isProgressEmpty ? .secondary : .primary)
                }
                .disabled(isProgressEmpty)
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
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
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
