//
//  AddCountView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/15/23.
//

import SwiftUI

struct AddCountView: View {
    @Environment(\.managedObjectContext) var moc
    @State private var countAmount: Int = 1
    @ObservedObject var habit: Habit
    var progress: Progress?
    @Binding var date: Date
    var habitManager: HabitManager
    @Binding var showAddCountAlert: Bool
    
    var isDateAfterToday: Bool {
        date.isAfter(Date())
    }
    
    var body: some View {
        Button {
            if habit.customCount {
                showAddCountAlert.toggle()
            } else {
                handleAddCount(habit.defaultCountNumber)
            }
        } label: {
            Image(systemName: "plus")
                .bold()
                .foregroundColor(.white)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isDateAfterToday ? .white.opacity(0) : .white.opacity(0.25))
        )
        .disabled(isDateAfterToday)
        .buttonStyle(.plain)
        .alert("Enter amount", isPresented: $showAddCountAlert) {
            TextField("Enter count amount", value: $countAmount, format: .number)
                .keyboardType(.numberPad)
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                handleAddCount(countAmount)
            }
        }
    }
    
    func handleAddCount(_ amount: Int) {
        if let progress = progress {
            habitManager.addNewCount(progress: progress, date: date, habit: habit, amount: amount)
        } else {
            habitManager.addNewProgress(date: date, amount: amount)
        }
        
        HapticManager.shared.simpleSuccess()
    }
}

struct AddCountView_Previews: PreviewProvider {
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
        
        return AddCountView(habit: habit, date: .constant(Date.now), habitManager: HabitManager(), showAddCountAlert: .constant(false))
    }
}
