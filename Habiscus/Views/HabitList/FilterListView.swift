//
//  FilterListView.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 1/25/24.
//

import SwiftUI

struct FilterListView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) private var dismiss
    @State private var editMode: EditMode = EditMode.active
    @Binding var showActive: Bool
    @Binding var showComplete: Bool
    @Binding var showSkipped: Bool
    @State var habits: [Habit]
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    reorderHabits()
                } label: {
                    Text("Reorder habits")
                }
                Section("Show sections") {
                    Group {
                        Toggle("Active", isOn: $showActive.animation())
                        Toggle("Complete", isOn: $showComplete.animation())
                        Toggle("Skipped", isOn: $showSkipped.animation())
                    }
                    .foregroundStyle(.primary)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func reorderHabits() -> some View {
        List {
            Section("Habits order") {
                ForEach(habits) { habit in
                    Text(habit.wrappedName)
                }
                .onMove(perform: move)
            }
        }
        .environment(\.editMode, $editMode)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        habits.move(fromOffsets: source, toOffset: destination)
        setHabitOrder()
    }
    
    func setHabitOrder() {
        habits.enumerated().forEach { currentIndex, habit in
            habit.order = Int16(currentIndex)
        }
    }
}

#Preview {
    FilterListView(showActive: .constant(true), showComplete: .constant(true), showSkipped: .constant(true), habits: [])
}
