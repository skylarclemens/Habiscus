//
//  HabitListView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/27/23.
//

import SwiftUI

struct NoHabitsView: View {
    @Binding var date: Date
    var body: some View {
        VStack {
            VStack(spacing: 4) {
                Text("No habits for \(date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct HabitListView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject private var navigator: Navigator
    @Binding var dateSelected: Date

    @FetchRequest var habits: FetchedResults<Habit>
    
    init(dateSelected: Binding<Date>, weekdayFilter: String) {
        self._dateSelected = dateSelected
        let isArchivedPredicate = NSPredicate(format: "isArchived == NO")
        let containsWeekdaysPredicate = NSPredicate(format: "weekdays CONTAINS[c] %@", weekdayFilter)
        let afterStartDatePredicate = NSPredicate(format: "startDate <= %@", dateSelected.wrappedValue as NSDate)
        self._habits = FetchRequest<Habit>(sortDescriptors: [
            SortDescriptor(\.createdAt, order: .reverse),
        ], predicate: NSCompoundPredicate(type: .and, subpredicates: [isArchivedPredicate, containsWeekdaysPredicate, afterStartDatePredicate]), animation: .default)
    }
    
    var openHabits: [Habit] {
        habits.filter {
            if let progress = $0.findProgress(from: dateSelected) {
                return !progress.isSkipped && !progress.isCompleted
            }
            return true
        }.sorted { (lhs, rhs) in
            return lhs.wrappedName < rhs.wrappedName
        }
    }
    
    var completedHabits: [Habit] {
        habits.filter {
            if let progress = $0.findProgress(from: dateSelected) {
                return !progress.isSkipped && progress.isCompleted
            }
            return false
        }.sorted { (lhs, rhs) in
            return lhs.wrappedName < rhs.wrappedName
        }
    }
    
    var skippedHabits: [Habit] {
        habits.filter {
            if let progress = $0.findProgress(from: dateSelected) {
                return progress.isSkipped
            }
            return false
        }.sorted { (lhs, rhs) in
            return lhs.wrappedName < rhs.wrappedName
        }
        
    }
    
    var body: some View {
        List {
            Section {
                ForEach(openHabits) { habit in
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
                ForEach(completedHabits) { habit in
                    HabitRowView(habit: habit, date: $dateSelected, progress: habit.findProgress(from: dateSelected))
                        .overlay(
                            NavigationLink {
                                HabitView(habit: habit, date: $dateSelected)
                            } label: {
                                EmptyView()
                            }.opacity(0)
                        )
                }
                
            }
            
            if skippedHabits.count > 0 {
                Section {
                    ForEach(skippedHabits) { habit in
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
                } header: {
                    Text("Skipped")
                        .font(.system(.title2, design: .rounded))
                        .textCase(nil)
                        .foregroundColor(.secondary)
                }
            }
        }
        .offset(y: -40)
        .listStyle(.grouped)
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 80)
        .navigationDestination(for: Habit.self) { habit in
            HabitView(habit: habit, date: $dateSelected)
        }
        .animation(.spring(), value: openHabits)
        .emptyState(isEmpty: habits.count == 0) {
            ScrollView {
                NoHabitsView(date: $dateSelected)
                    .padding()
            }
        }
    }
}

struct HabitListView_Previews: PreviewProvider {
    static var previews: some View {
        Previewing(withData: \.habits) {
            NavigationStack {
                HabitListView(dateSelected: .constant(Date()), weekdayFilter: "Sunday, Monday, Tuesday")
            }
        }
    }
}
