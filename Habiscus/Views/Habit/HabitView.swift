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
    
    private var currentStreak: Int {
        return habit.getCurrentStreak()
    }
    
    private var longestStreak: Int {
        return habit.getLongestStreak()
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
        ZStack(alignment: .top) {
            Rectangle()
                .fill(Color(UIColor.secondarySystemBackground))
                .ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(habit.wrappedName)
                            .font(.system(.largeTitle, design: .rounded))
                            .foregroundColor(.white)
                        Text("Goal: \(habit.goalNumber) \(habit.goalFrequencyString)")
                            .foregroundColor(.white.opacity(0.9))
                    }
                    Spacer()
                    HStack {
                        Button {
                            simpleUndo()
                            habitManager.undoLastCount(from: date)
                        } label: {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                                .renderingMode(.original)
                                .font(.system(size: 38))
                                .foregroundColor(habit.habitColor)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, y: 8)
                            
                        }
                        .accessibilityLabel("Undo last count")
                        GoalCounterView(habit: habit, size: 60, date: $date)
                        Button {
                            var wasProgressJustCompleted = false
                            
                            if let progress = progress {
                                wasProgressJustCompleted = habitManager.addNewCount(progress: progress, date: date, habit: habit)
                            } else {
                                wasProgressJustCompleted = habitManager.addNewProgress(date: date)
                            }
                            
                            if wasProgressJustCompleted {
                                HapticManager.instance.completionSuccess()
                                SoundManager.instance.playCompleteSound(sound: .complete)
                            } else {
                                simpleSuccess()
                            }
                        } label: {
                            Image(systemName: "plus")
                                .bold()
                                .foregroundColor(.white)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(habit.habitColor)
                                        .shadow(color: Color.black.opacity(0.1), radius: 10, y: 8)
                                )
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 10, y: 8)
                    .shadow(color: habit.habitColor.opacity(0.3), radius: 10, y: 8)
                    .blur(radius: !isSkipped ? 0 : 5)
                    .disabled(isSkipped)
                    .overlay(
                        ZStack {
                            if isSkipped {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(UIColor.secondarySystemBackground).opacity(0.33))
                                    .opacity(0.8)
                                Text("Skipped today")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 10)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16))
                        .contextMenu {
                            Button {
                                
                            } label: {
                                Button {
                                    if let progress = progress {
                                        habitManager.setProgressSkip(progress: progress, skip: false)
                                    }
                                } label: {
                                    Label("Undo skip", systemImage: "backward.end")
                                }
                            }
                        }
                        .opacity(isSkipped ? 1 : 0)
                        .animation(.default, value: isSkipped)
                        
                    )
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(habit.habitColor)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, y: 8)
                        .shadow(color: habit.habitColor.opacity(0.3), radius: 10, y: 8)
                )
                .padding(.horizontal)
                
                HStack {
                    VStack {
                        Text("Longest streak")
                            .font(.caption)

                            Text("\(longestStreak) \(longestStreak == 1 ? "day" : "days")")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(habit.habitColor)
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.regularMaterial)
                            .shadow(color: Color.black.opacity(0.1), radius: 12, y: 8)
                    }
                    
                    VStack {
                        Text("Current streak")
                            .font(.caption)
                        
                        Text("\(currentStreak) \(currentStreak == 1 ? "day" : "days")")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(habit.habitColor)
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.regularMaterial)
                            .shadow(color: Color.black.opacity(0.1), radius: 12, y: 8)
                    }
                    
                    VStack {
                        Text("Success %")
                            .font(.caption)

                        Text("\(Int(habit.successPercentage))%")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(habit.habitColor)
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.regularMaterial)
                            .shadow(color: Color.black.opacity(0.1), radius: 12, y: 8)
                    }
                }
                .frame(maxWidth: .infinity)
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
        .navigationTitle(habit.wrappedName)
        .navigationBarTitleDisplayMode(.inline)
        .tint(.white)
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
        //count.progress = progress
        //progress.addToCounts(count)
        progress.isSkipped = true
        habit.name = "Test"
        habit.createdAt = Date.now
        habit.addToProgress(progress)
        habit.goal = 1
        habit.goalFrequency = 1
        
        return NavigationStack {
            HabitView(habit: habit, date: .constant(Date.now))
        }
    }
}
