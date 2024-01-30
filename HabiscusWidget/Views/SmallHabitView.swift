//
//  SmallHabitView.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/4/23.
//

import SwiftUI
import WidgetKit

struct SmallHabitView: View {
    @State var habit: HabitEntity
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                WidgetGoalCounter(size: 40, date: Date(), count: habit.count, goal: habit.goal, icon: habit.icon, checkmarkSize: 10)
                Spacer()
                if habit.progressMethod == "counts" {
                    if #available(iOS 17.0, *) {
                        Button(intent: AddCountToHabit(habit: habit, date: Date())) {
                            Label("Add", systemImage: "plus")
                        }
                        .labelStyle(.iconOnly)
                        .tint(.white)
                    }
                }
            }
            HStack {
                VStack(alignment: .leading) {
                    Text(habit.name)
                        .font(.system(size: 24, design: .rounded))
                        .bold()
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                        .padding(.trailing)
                        .lineLimit(2)
                    if #available(iOS 17.0, *) {
                        Group {
                            Text("\(habit.count)") +
                            Text(" / \(habit.goal)") +
                            Text(" \(habit.unit)")
                        }
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .bold()
                        .foregroundColor(.white.opacity(0.75))
                        .invalidatableContent()
                    } else {
                        Group {
                            Text("\(habit.count)") +
                            Text(" / \(habit.goal)") +
                            Text(" \(habit.unit)")
                        }
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .bold()
                        .foregroundColor(.white.opacity(0.75))
                    }
                }
                Spacer()
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .widgetBackground(Color(habit.color))
    }
}

struct SmallHabitView_Previews: PreviewProvider {
    static var previews: some View {
        SmallHabitView(habit: HabitEntity.example)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

/*#Preview(as: .systemSmall) {
    HabiscusWidget()
} timeline: {
    SimpleEntry(habit: HabitEntity.example, date: Date())
}*/
