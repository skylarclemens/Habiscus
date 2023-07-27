//
//  ContentView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/21/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.createdAt, order: .reverse),
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
    
    @State private var addHabitOpen = false
    @State private var dateSelected: Date = Date()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text(checkCloseDate().uppercased())
                    .font(.subheadline)
                    .frame(height: 16)
                Text(dateSelected, format: .dateTime.month().day())
                    .font(.system(size: 40, weight: .medium, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
            }
            .animation(.spring(), value: dateSelected)
            
            
            WeekView(selectedDate: $dateSelected)
                .frame(height: 60)
                .padding(.bottom, 16)
                .offset(y: -20)
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
                    .onDelete(perform: removeHabits)
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
                        .onDelete(perform: removeHabits)
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
            .toolbar {
                Button {
                    addHabitOpen = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            .sheet(isPresented: $addHabitOpen) {
                AddHabitView()
            }
        }
        .tint(.pink)
    }
    
    func removeHabits(at offsets: IndexSet) {
        for offset in offsets {
            let habit = habits[offset]
            moc.delete(habit)
        }
        try? moc.save()
    }
    
    func checkCloseDate() -> String {
        if Calendar.current.isDateInToday(dateSelected) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(dateSelected) {
            return "Yesterday"
        } else if Calendar.current.isDateInTomorrow(dateSelected) {
            return "Tomorrow"
        }
        return ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataController = DataController()
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
