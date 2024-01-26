//
//  StartActionsView.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/11/23.
//

import SwiftUI

struct StartActionsView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var habit: Habit
    var progress: Progress?
    @Binding var date: Date
    var habitManager: HabitManager
    @StateObject var actionManager = ActionManager()
    
    @State var showActionsSheet = false
    var isDateAfterToday: Bool {
        date.isAfter(Date())
    }
    
    var body: some View {
        Button {
            actionManager.createProgressActions(habit: habit, progress: progress, date: date)
            actionManager.startProgressActions()
            HapticManager.shared.simpleSuccess()
        } label: {
            Image(systemName: "play.fill")
                .bold()
                .foregroundColor(.white)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isDateAfterToday ? .white.opacity(0) : .white.opacity(0.25))
        )
        .buttonStyle(.plain)
        .disabled(isDateAfterToday)
        .sheet(item: $actionManager.currentAction, onDismiss: { showActionsSheet = false }) { action in
            ActionView(action: action, manager: actionManager)
        }
    }
}

struct StartActionsView_Previews: PreviewProvider {
    static var dataController = DataController()
    static var moc = dataController.container.viewContext
    static var habitManager = HabitManager()
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
        
        return VStack {
            StartActionsView(habit: habit, date: .constant(Date.now), habitManager: HabitManager())
        }.padding()
        .background(.pink)
        .clipShape(.rect(cornerRadius: 10))
    }
}
