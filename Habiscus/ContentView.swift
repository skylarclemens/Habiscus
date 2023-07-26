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
                } header: {
                    DatePicker("Date", selection: $dateSelected, in: ...Date(), displayedComponents: [.date])
                            .labelsHidden()
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
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 80)
            .navigationTitle("Home")
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
}

struct ContentView_Previews: PreviewProvider {
    static var dataController = DataController()
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
