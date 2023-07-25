//
//  HabitRow.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/24/23.
//

import SwiftUI

struct HabitRow: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var habit: Habit
    
    var body: some View {
        HStack {
            Text(habit.wrappedName)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.white)
            Spacer()
            Text(habit.countsArray.count, format: .number)
                .font(.title2)
                .foregroundColor(.white)
            Button {
                simpleSuccess()
                let newCount = Count(context: moc)
                newCount.id = UUID()
                newCount.count += 1
                newCount.created_at = Date.now
                newCount.habit = habit
                try? moc.save()
            } label: {
                Image(systemName: "plus")
            }
            .tint(.white)
            .buttonStyle(.bordered)
        }
        .listRowBackground(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(habit.habitColor).opacity(0.8))
                .padding(.vertical, 5)
        )
        .listRowSeparator(.hidden)
    }
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct HabitRow_Previews: PreviewProvider {
    static var dataController = DataController()
    static var moc = dataController.container.viewContext
    static var previews: some View {
        let habit = Habit(context: moc)
        let count = Count(context: moc)
        count.count += 1
        count.created_at = Date.now
        count.habit = habit
        habit.name = "Test"
        habit.created_at = Date.now
        habit.addToCounts(count)
        return List {
            HabitRow(habit: habit)
        }.environment(\.defaultMinListRowHeight, 90)
    }
}
