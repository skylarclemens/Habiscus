//
//  ArchiveView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/21/23.
//

import SwiftUI

struct ArchiveView: View {
    @Environment(\.managedObjectContext) var moc
    @State var dateSelected: Date = Date()

    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.createdAt, order: .reverse),
    ], predicate: NSPredicate(format: "isArchived == YES"), animation: .default) var habits: FetchedResults<Habit>
    
    var body: some View {
        List {
            ForEach(habits) { habit in
                HabitRowView(habit: habit, date: $dateSelected, progress:
                                habit.findProgress(from: dateSelected))
                .overlay(
                    NavigationLink {
                        HabitView(habit: habit, date: $dateSelected)
                    } label: {
                        EmptyView()
                    }.opacity(0)
                )
            }
        }
        .listStyle(.grouped)
        .navigationTitle("Archive")
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var dataController = DataController.shared
    static var previews: some View {
        NavigationView {
            ArchiveView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
