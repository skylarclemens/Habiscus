//
//  WidgetGoalCounter.swift
//  HabiscusWidgetExtension
//
//  Created by Skylar Clemens on 1/30/24.
//

import SwiftUI
import WidgetKit

struct WidgetGoalCounter: View {
    var size: CGFloat = 50
    var date: Date
    var count: Int
    var goal: Int
    var icon: String
    var habitType: String = "build"
    var showCheckmark: Bool = true
    var checkmarkSize: CGFloat = 15
    var color: Color = .white
    
    private var goalCompletion: Double {
        let goalCount = Double(count) / Double(goal)
        if habitType == "quit" {
            let quitCount = 1 - goalCount
            return min(max(quitCount, 0), 1)
        }
        return min(max(goalCount, 0), 1)
    }
    
    var body: some View {
        ZStack {
            HStack {
                if goalCompletion >= 1 && showCheckmark {
                    AnimatedCheckmark(animationDuration: 1.25, size: checkmarkSize)
                } else {
                    if !icon.isEmpty {
                        IconView(char: icon, size: 16)
                    } else {
                        Text(count, format: .number)
                            .font(.system(.title2, design: .rounded))
                            .bold()
                            .foregroundColor(color)
                    }
                }
            }
            ProgressView(value: goalCompletion > 1 ? 1.0 : goalCompletion, total: 1.0)
                .progressViewStyle(CircleProgressStyle(color: color, strokeWidth: 6))
                .frame(width: size)
                .animation(.easeOut(duration: 1.25), value: count)
        }
    }
}

struct WidgetGoalCounter_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            WidgetGoalCounter(size: 50, date: Date(), count: 1, goal: 2, icon: "🤩", habitType: "build", checkmarkSize: 10)
        }
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .widgetBackground(Color.habiscusPink)
    }
}
