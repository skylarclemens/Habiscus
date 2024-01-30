//
//  SmallMultiHabitView.swift
//  HabiscusWidgetExtension
//
//  Created by Skylar Clemens on 1/29/24.
//

import SwiftUI
import WidgetKit

struct SmallMultiHabitView: View {
    @State var habits: [HabitEntity]
    let columns = [GridItem(.flexible(), alignment: .center), GridItem(.flexible(), alignment: .center)]
    
    var body: some View {
        VStack(alignment: .leading) {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(habits) { habit in
                    if #available(iOS 17.0, *) {
                        if habit.progressMethod == "counts" {
                            Button(intent: AddCountToHabit(habit: habit, date: Date())) {
                                WidgetGoalCounter(size: 50, date: Date(), count: habit.count, goal: habit.goal, icon: habit.icon, habitType: habit.type, showCheckmark: false, color: Color(habit.color))
                            }
                            .buttonStyle(.plain)
                            .padding(5)
                            .shadow(color: Color.black.opacity(0.1), radius: 3, y: 0)
                            .shadow(color: Color(habit.color).opacity(0.2), radius: 2, y: 0)
                        } else {
                            Link(destination: habit.url!) {
                                WidgetGoalCounter(size: 50, date: Date(), count: habit.count, goal: habit.goal, icon: habit.icon, habitType: habit.type, showCheckmark: false, color: Color(habit.color))
                            }
                        }
                    } else {
                        WidgetGoalCounter(size: 50, date: Date(), count: habit.count, goal: habit.goal, icon: habit.icon, showCheckmark: false, color: Color(habit.color))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .widgetBackground(Color(UIColor.systemBackground))
    }
}

struct SmallMultiHabitView_Previews: PreviewProvider {
    static var previews: some View {
        SmallMultiHabitView(habits: [HabitEntity.example, HabitEntity.example2, HabitEntity.example3])
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
