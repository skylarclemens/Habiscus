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
        SortDescriptor(\.isCompleted),
        SortDescriptor(\.createdAt, order: .reverse)
    ]) var habits: FetchedResults<Habit>
    
    @State private var addHabitOpen = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(habits) { habit in
                        HabitRowView(habit: habit)
                            .overlay(
                                NavigationLink {
                                    HabitView(habit: habit)
                                } label: {
                                    EmptyView()
                                }.opacity(0)
                            )
                            .animation(Animation.easeInOut, value: habit)
                    }
                    .onDelete(perform: removeHabits)
                } header: {
                    Text("Today")
                        .textCase(nil)
                        .foregroundColor(.primary)
                        .font(.title)
                }
            }
            .listStyle(.grouped)
            .environment(\.defaultMinListRowHeight, 80)
            .navigationTitle("Habiscus")
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
