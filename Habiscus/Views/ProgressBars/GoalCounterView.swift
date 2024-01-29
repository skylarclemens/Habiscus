//
//  GoalCounterView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/27/23.
//

import SwiftUI

struct GoalCounterView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var habit: Habit
    var size: CGFloat = 50
    @Binding var date: Date
    var showIcon: Bool = false
    var checkmarkSize: CGFloat = 15
    
    private var currentGoalCount: Int {
        if let progress = habit.findProgress(from: date) {
            return progress.totalCount
        }
        return 0
    }
    private var goalCompletion: Double {
        let goalCount = Double(currentGoalCount) / Double(habit.goalNumber)
        if habit.wrappedType == .quit {
            let quitCount = 1 - goalCount
            return min(max(quitCount, 0), 1)
        }
        return min(max(goalCount, 0), 1)
    }
    private var goalComplete: Bool {
        if habit.wrappedType == .quit {
            return currentGoalCount <= habit.goalNumber
        }
        return currentGoalCount >= habit.goalNumber
    }
    
    var body: some View {
        ZStack {
            HStack {
                if goalComplete {
                    AnimatedCheckmark(animationDuration: 1.25, size: checkmarkSize)
                } else {
                    if let char = habit.icon,
                       showIcon {
                        IconView(char: char)
                    } else {
                        Text(currentGoalCount, format: .number)
                            .font(.system(.title2, design: .rounded))
                            .bold()
                            .foregroundColor(.white)
                    }
                }
            }
            ProgressView(value: goalCompletion, total: 1.0)
                .progressViewStyle(CircleProgressStyle(color: .white, strokeWidth: 6))
                .frame(width: size)
                .animation(.easeOut(duration: 1.25), value: currentGoalCount)
        }
        .padding(.trailing, 6)
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
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
    var color: Color = .white
    @State var size: CGFloat = 15
    @State private var innerTrimEnd: CGFloat = 0
    @State private var scale = 1.0
    var body: some View {
        HStack {
            Checkmark()
                .trim(from: 0, to: innerTrimEnd)
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .frame(width: size, height: size)
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

struct GoalCounterView_Previews: PreviewProvider {
    static var previews: some View {
        Previewing(\.quitHabit) { habit in
            GoalCounterView(habit: habit, date: .constant(Date()))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.pink)
                )
        }
    }
}
