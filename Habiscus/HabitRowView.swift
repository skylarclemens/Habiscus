//
//  HabitRow.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/24/23.
//

import SwiftUI

extension Date {
    func daysBetweenDates(to date: Date) -> Int? {
        let dateFromComponent = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self))
        let dateToComponent = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: date))
        let components = Calendar.current.dateComponents([.day], from: dateFromComponent ?? self, to: dateToComponent ?? date)
        return components.day
    }
}

struct HabitRowView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var habit: Habit
    @State private var animated: Bool = false
    @Binding var date: Date
    
    var isCompleted: Bool = false
    
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
                    simpleSuccess()
                    habitManager.addNewCount(date: date)
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
                    habitManager.undoLastCount()
                } label: {
                    Label("Undo last count", systemImage: "arrow.uturn.backward")
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
        count.count += 1
        count.createdAt = Date.now
        count.habit = habit
        habit.name = "Test"
        habit.createdAt = Date.now
        habit.addToCounts(count)
        habit.goal = 1
        habit.goalFrequency = 1
        return List {
            HabitRowView(habit: habit, date: .constant(Date()))
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
