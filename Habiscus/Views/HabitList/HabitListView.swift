//
//  HabitListView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/27/23.
//

import SwiftUI



struct HabitListView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject private var navigator: Navigator
    @State private var editMode: EditMode = EditMode.active
    @Binding var dateSelected: Date
    
    @State private var showActive: Bool = true
    @State private var showComplete: Bool = true
    @State private var showSkipped: Bool = true
    @State private var openListFilters: Bool = false

    @FetchRequest var habits: FetchedResults<Habit>
    
    init(dateSelected: Binding<Date>, weekdayFilter: String) {
        self._dateSelected = dateSelected
        let isArchivedPredicate = NSPredicate(format: "isArchived == NO")
        let containsWeekdaysPredicate = NSPredicate(format: "weekdays CONTAINS[c] %@", weekdayFilter)
        let afterStartDatePredicate = NSPredicate(format: "startDate <= %@", dateSelected.wrappedValue as NSDate)
        self._habits = FetchRequest<Habit>(sortDescriptors: [
            SortDescriptor(\.order, order: .forward),
            SortDescriptor(\.name, order: .forward),
        ], predicate: NSCompoundPredicate(type: .and, subpredicates: [isArchivedPredicate, containsWeekdaysPredicate, afterStartDatePredicate]), animation: .default)
    }
    
    var allHabits: [Habit] {
        habits.map { $0 }
    }
    
    var openHabits: [Habit] {
        habits.filter {
            if let progress = $0.findProgress(from: dateSelected) {
                return !progress.isSkipped && !progress.isCompleted
            }
            return true
        }
    }
    
    var completedHabits: [Habit] {
        habits.filter {
            if let progress = $0.findProgress(from: dateSelected) {
                return !progress.isSkipped && progress.isCompleted
            }
            return false
        }
    }
    
    var skippedHabits: [Habit] {
        habits.filter {
            if let progress = $0.findProgress(from: dateSelected) {
                return progress.isSkipped
            }
            return false
        }
    }
    
    var body: some View {
        List {
            Section {
                if openHabits.count > 0 && showActive {
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
                }
            } header: {
                HStack {
                    Spacer()
                    Button {
                        openListFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.habiscusPink)
                    }
                }
                .textCase(nil)
                .foregroundStyle(.primary)
            }
            .listRowInsets(EdgeInsets(top: 16, leading: 24, bottom: 8, trailing: 24))
            if completedHabits.count > 0 && showComplete {
                Section {
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
                } header: {
                    Text("Complete")
                        .textCase(nil)
                        .font(.system(.title3, design: .rounded, weight: .medium))
                        .foregroundStyle(.primary)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 8, trailing: 24))
            }
            if skippedHabits.count > 0 && showSkipped {
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
                        .textCase(nil)
                        .font(.system(.title3, design: .rounded, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 8, trailing: 24))
            }
        }
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
        .sheet(isPresented: $openListFilters, onDismiss: filterDismissed) {
            FilterListView(showActive: $showActive, showComplete: $showComplete, showSkipped: $showSkipped, habits: allHabits)
                .presentationDetents([.medium])
        }
    }
    
    private func filterDismissed() {
        if moc.hasChanges {
            try? moc.save()
        }
    }
}

struct HabitListView_Previews: PreviewProvider {
    static var previews: some View {
        Previewing(withData: \.habits) {
            NavigationStack {
                HabitListView(dateSelected: .constant(Date()), weekdayFilter: "Sunday, Monday, Tuesday")
                    .padding(.vertical, 24)
            }
        }
    }
}
