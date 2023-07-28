//
//  HabitListView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/27/23.
//

import SwiftUI

struct HabitListView: View {
    @Environment(\.managedObjectContext) var moc
    @Binding var dateSelected: Date

    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.createdAt, order: .reverse)
    ], animation: .default) var habits: FetchedResults<Habit>

    var openHabits: [Habit] {
        habits.filter {
            $0.goalNumber > $0.findGoalCount(on: dateSelected)
        }
    }
    var completedHabits: [Habit] {
        habits.filter {
            $0.goalNumber <= $0.findGoalCount(on: dateSelected)
        }
    }
    
    var body: some View {
        List {
            Section {
                ForEach(openHabits) { habit in
                    HabitRowView(habit: habit, date: $dateSelected)
                        .overlay(
                            NavigationLink {
                                HabitView(habit: habit, date: $dateSelected)
                            } label: {
                                EmptyView()
                            }.opacity(0)
                        )
                }
            }
            
            if completedHabits.count > 0 {
                Section {
                    ForEach(completedHabits) { habit in
                        HabitRowView(habit: habit, date: $dateSelected, isCompleted: true)
                            .overlay(
                                NavigationLink {
                                    HabitView(habit: habit, date: $dateSelected)
                                } label: {
                                    EmptyView()
                                }.opacity(0)
                            )
                    }
                } header: {
                    Text("Complete")
                        .font(.system(.title2 , design: .rounded))
                        .textCase(nil)
                        .foregroundColor(.secondary)
                }
            }
        }
        .offset(y: -40)
        .listStyle(.grouped)
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 80)
        .animation(.spring(), value: openHabits)
        
    }
}

struct HabitListView_Previews: PreviewProvider {
    static var dataController = DataController()
    static var previews: some View {
        HabitListView(dateSelected: .constant(Date()))
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
