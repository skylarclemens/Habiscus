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
    @State private var showAddCountAlert: Bool = false
    @ObservedObject var habit: Habit
    var progress: Progress?
    @Binding var date: Date
    var habitManager: HabitManager
    
    var isDateAfterToday: Bool {
        date.isAfter(Date())
    }
    
    var body: some View {
        Button {
            showAddCountAlert.toggle()
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
                if let progress = progress { habitManager.addNewCount(progress: progress, date: date, habit: habit, amount: countAmount)
                } else {
                    habitManager.addNewProgress(date: date, amount: countAmount)
                }
                
                HapticManager.shared.simpleSuccess()
            }
        }
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
        
        return AddCountView(habit: habit, date: .constant(Date.now), habitManager: HabitManager())
    }
}
