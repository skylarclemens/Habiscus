//
//  HabitView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/23/23.
//

import SwiftUI
import Charts

struct HabitView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var habit: Habit
    @Binding var date: Date
    
    private var progress: Progress? {
        return habit.findProgress(from: date)
    }
    
    private var habitManager: HabitManager {
        HabitManager(context: moc, habit: habit)
    }
    
    private var showEntries: Bool {
        if let progress = progress {
            return progress.countsArray.count > 0
        }
        return false
    }
    
    private var isSkipped: Bool {
        if let progress = progress {
            return progress.isSkipped
        }
        return false
    }
    
    @State var showSkippedOverlay: Bool = false
    
    init(habit: Habit, date: Binding<Date>) {
        self.habit = habit
        self._date = date
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color(UIColor.secondarySystemBackground))
                .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(habit.habitColor)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, y: 8)
                            .shadow(color: habit.habitColor.opacity(0.3), radius: 10, y: 8)
                            .padding(.horizontal)
                        VStack(alignment: .leading) {
                            HStack {
                                GoalCounterView(habit: habit, size: 60, date: $date, showIcon: true)
                                VStack(alignment: .leading) {
                                    Text(habit.wrappedName)
                                        .font(.system(size: 38, design: .rounded))
                                        .bold()
                                        .foregroundColor(.white)
                                    if habit.icon != nil {
                                        Text("\(progress?.totalCount ?? 0) / \(habit.goalNumber) \(habit.goalMetric)")
                                            .font(.system(.callout, design: .rounded))
                                            .bold()
                                            .foregroundColor(.white.opacity(0.75))
                                    }
                                }
                                Spacer()
                                AddCountView(habit: habit, progress: progress, date: $date, habitManager: habitManager)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        .padding(.horizontal)
                    }
                }
                
                StatisticsView(habit: habit)
                    .padding()
                
                VStack {
                    CalendarView(habit: habit, date: $date, size: 40, color: habit.habitColor)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.regularMaterial)
                                .shadow(color: Color.black.opacity(0.1), radius: 12, y: 8)
                        )
                        .padding(.horizontal)
                }
                
                VStack {
                    CountGridView(habit: habit, size: 14, spacing: 4)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.regularMaterial)
                                .shadow(color: Color.black.opacity(0.1), radius: 12, y: 8)
                        )
                        .padding()
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    if showEntries {
                        VStack(alignment: .leading) {
                            Section {
                                ForEach(progress?.countsArray ?? []) { count in
                                    HStack(spacing: 12) {
                                        Text("+1")
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .fill(habit.habitColor.opacity(0.8))
                                                    .shadow(color: habit.habitColor.opacity(0.3), radius: 4, y: 2)
                                            )
                                        Text(count.dateString)
                                    }
                                }
                            } header: {
                                Text("Entries")
                                    .font(.headline)
                                    .padding(.bottom, 4)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.regularMaterial)
                                .shadow(color: Color.black.opacity(0.1), radius: 12, y: 8)
                        )
                        .padding()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                    }
                }
                .opacity(showEntries ? 1 : 0)
                .animation(.spring(), value: showEntries)
            }
        }
    }
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    func simpleUndo() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    func completeHaptic() {
        
    }
}

struct HabitView_Previews: PreviewProvider {
    static var dataController = DataController()
    static var moc = dataController.container.viewContext
    static var previews: some View {
        let habit = Habit(context: moc)
        let count = Count(context: moc)
        let progress = Progress(context: moc)
        progress.id = UUID()
        progress.date = Date.now
        progress.isCompleted = true
        count.id = UUID()
        count.createdAt = Date.now
        count.date = Date.now
        progress.isSkipped = false
        habit.name = "Test"
        habit.icon = "🤩"
        habit.weekdays = "Monday, Wednesday, Friday"
        habit.createdAt = Date.now
        habit.addToProgress(progress)
        habit.goal = 1
        habit.goalFrequency = 1
        
        return NavigationStack {
            HabitView(habit: habit, date: .constant(Date.now))
                .navigationTitle("Test")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
