//
//  HabitRow.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/24/23.
//

import SwiftUI

extension Date {
    func fullDistance(from date: Date, resultIn component: Calendar.Component, calendar: Calendar = .current) -> Int? {
        calendar.dateComponents([component], from: self, to: date).value(for: component)
    }
}

struct Checkmark: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.size.width
        let height = rect.size.height
        
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0.5 * height))
        path.addLine(to: CGPoint(x: 0.4 * width, y: 1.0 * height))
        path.addLine(to: CGPoint(x: width, y: 0))
        return path
    }
}

struct AnimatedCheckmark: View {
    var animationDuration: Double = 0.75
    @State private var innerTrimEnd: CGFloat = 0
    @State private var scale = 1.0
    var body: some View {
        HStack {
            Checkmark()
                .trim(from: 0, to: innerTrimEnd)
                .stroke(.white, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .frame(width: 15, height: 15)
                .scaleEffect(scale)
        }
        .onAppear {
            animate()
        }
    }
    
    func animate() {
        withAnimation(
            .easeInOut(duration: animationDuration * 0.7)
        ) {
            innerTrimEnd = 1.0
        }
        
        withAnimation(
            .linear(duration: animationDuration * 0.2)
            .delay(animationDuration * 0.6)
        ) {
            scale = 1.1
        }
        
        withAnimation(
            .linear(duration: animationDuration * 0.1)
            .delay(animationDuration * 0.9)
        ) {
            scale = 1
        }
    }
}

struct CircleProgressStyle: ProgressViewStyle {
    let color: Color
    var strokeWidth: Double = 5.0
    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0
        
        return ZStack {
            Circle()
                .stroke(color.opacity(0.5), lineWidth: strokeWidth)
                .overlay (
                    Circle()
                        .trim(from: 0, to: fractionCompleted)
                        .stroke(color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                )
        }
    }
}

struct GoalCounterView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var habit: Habit
    
    @State private var currentGoalCount: Int = 0
    private var goalCompletion: Double {
        Double(currentGoalCount) / Double(habit.goalNumber)
    }
    var date: Date
    
    var body: some View {
        ZStack {
            HStack {
                if goalCompletion >= 1 {
                    AnimatedCheckmark(animationDuration: 1.25)
                } else {
                    Text(currentGoalCount, format: .number)
                        .bold()
                        .foregroundColor(.white)
                }
            }
            ProgressView(value: goalCompletion > 1 ? 1.0 : goalCompletion, total: 1.0)
                .progressViewStyle(CircleProgressStyle(color: .white, strokeWidth: 6))
                .frame(width: 50)
                .animation(.easeOut(duration: 1.5).delay(0.25), value: currentGoalCount)
        }
        .padding(.trailing, 6)
        .onAppear {
            currentGoalCount = habit.findCurrentGoalCount(on: date)
        }
        .onReceive(habit.objectWillChange) {
            if habit.isDeleted {
                return
            }
            currentGoalCount = habit.findCurrentGoalCount(on: date)
        }
    }
}

struct HabitRowView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var habit: Habit
    var date: Date
    
    var isCompleted: Bool {
        habit.goalNumber <= habit.findCurrentGoalCount(on: date)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(habit.habitColor.opacity(0.8))
                .padding(.vertical, 8)
                .shadow(color: .black.opacity(isCompleted ? 0 : 0.1), radius: 6, y: 3)
                .shadow(color: habit.habitColor.opacity(isCompleted ? 0 : 0.5), radius: 4, y: 3)
            HStack {
                GoalCounterView(habit: habit, date: date)
                Text(habit.wrappedName)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                Spacer()
                Button {
                    simpleSuccess()
                    let newCount = Count(context: moc)
                    newCount.id = UUID()
                    newCount.count += 1
                    newCount.createdAt = Calendar.current.isDateInToday(date) ? Date.now : date
                    newCount.habit = habit
                    habit.addToCounts(newCount)
                    try? moc.save()
                } label: {
                    Image(systemName: "plus")
                }
                .tint(.white)
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .opacity(isCompleted ? 0.5 : 1)
        
    }
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct HabitRowView_Previews: PreviewProvider {
    static var dataController = DataController()
    static var moc = dataController.container.viewContext
    static var previews: some View {
        let habit = Habit(context: moc)
        let count = Count(context: moc)
        count.count += 1
        count.createdAt = Date.now
        count.habit = habit
        habit.name = "Test"
        habit.createdAt = Date.now
        habit.addToCounts(count)
        habit.goal = 1
        habit.goalFrequency = 1
        return List {
            HabitRowView(habit: habit, date: Date())
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        
                    }
                }
            HabitRowView(habit: habit, date: Date())
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        
                    }
                }
        }
        .listStyle(.grouped)
        .environment(\.defaultMinListRowHeight, 80)
    }
}
