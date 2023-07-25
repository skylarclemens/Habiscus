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
    
    @State private var currentGoal: Int = 0
    
    var body: some View {
        ZStack {
            HStack {
                if currentGoal/habit.goalNumber >= 1 {
                    AnimatedCheckmark()
                } else {
                    Text(currentGoal, format: .number)
                        .bold()
                        .foregroundColor(.white)
                }
            }
            ProgressView(value: Double(currentGoal) / Double(habit.goalNumber), total: 1.0)
                .progressViewStyle(CircleProgressStyle(color: .yellow, strokeWidth: 5))
                .frame(width: 50)
                .animation(.easeOut(duration: 1.5).delay(0.25), value: currentGoal)
        }
        .padding(.trailing, 6)
        .onAppear {
            findCurrentGoal()
        }
        .onReceive(habit.objectWillChange) {
            findCurrentGoal()
        }
    }
    
    func findCurrentGoal() {
        let today = Date.now
        
        let currentGoalCounts = habit.countsArray.filter {
            let distance = today.fullDistance(from: $0.wrappedCreatedDate, resultIn: .day)!
            return distance <= habit.goalFrequencyNumber - 1
        }
        
        currentGoal = currentGoalCounts.count
    }
}

struct HabitRowView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var habit: Habit
    
    var body: some View {
        HStack {
            GoalCounterView(habit: habit)
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
                newCount.createdAt = Date.now
                newCount.habit = habit
                habit.addToCounts(newCount)
                try? moc.save()
            } label: {
                Image(systemName: "plus")
            }
            .tint(.white)
            .buttonStyle(.bordered)
        }
        .listRowBackground(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(habit.habitColor).opacity(0.8))
                .padding(.vertical, 5)
        )
        .listRowSeparator(.hidden)
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
            HabitRowView(habit: habit)
        }.environment(\.defaultMinListRowHeight, 90)
    }
}
