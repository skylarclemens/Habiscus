//
//  HabiscusWidget.swift
//  HabiscusWidget
//
//  Created by Skylar Clemens on 11/4/23.
//

import WidgetKit
import SwiftUI
import CoreData

struct SimpleEntry: TimelineEntry {
    var habit: HabitEntity?
    var date: Date
    
    static var placeholder: Self {
        Self(habit: HabitEntity.example, date: .now)
    }
}

struct HabitIntentProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry.placeholder
    }
    
    func snapshot(for configuration: WidgetHabitSelection, in context: Context) async -> SimpleEntry {
        SimpleEntry.placeholder
    }
    
    func timeline(for configuration: WidgetHabitSelection, in context: Context) async -> Timeline<SimpleEntry> {
        let habit = try? HabitsManager.shared.findHabit(id: configuration.habit.id)
        var entries: [SimpleEntry] = []
        if let habit {
            let habitEntity = HabitEntity(habit: habit)
            let entry = SimpleEntry(habit: habitEntity, date: Date())
            entries.append(entry)
        }
        return Timeline(entries: entries, policy: .never)
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        do {
            let habits = try HabitsManager.shared.getAllActiveHabits()
            if let habit = habits.first {
                let habitEntity = HabitEntity(habit: habit)
                let entry = SimpleEntry(habit: habitEntity, date: Date())
                completion(entry)
            } else {
                throw Errors.notFound
            }
        } catch {
            print(error)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        do {
            let habits = try HabitsManager.shared.getAllActiveHabits()
            var entries: [SimpleEntry] = []

            let entryDate = Date()
            if let habit = habits.first {
                let habitEntity = HabitEntity(habit: habit)
                let entry = SimpleEntry(habit: habitEntity, date: entryDate)
                entries.append(entry)
            }

            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        } catch {
            print(error)
        }
    }
}

struct HabiscusWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            if let habit = entry.habit {
                SmallHabitView(habit: habit)
                    .widgetURL(habit.url)
            }
        }
    }
}

struct HabiscusWidget: Widget {
    let dataController = DataController.shared
    let kind: String = "HabitWidget"

    var body: some WidgetConfiguration {
        makeWidgetConfiguration()
            .configurationDisplayName("Habit Detail")
            .description("Keep track of your habit's details.")
    }
    
    func makeWidgetConfiguration() -> some WidgetConfiguration {
        if #available(iOS 17.0, *) {
            return AppIntentConfiguration(kind: kind,
                                          intent: WidgetHabitSelection.self,
                                          provider: HabitIntentProvider()) { entry in
                HabiscusWidgetEntryView(entry: entry)
                    .padding()
            }.supportedFamilies([.systemSmall])
                .contentMarginsDisabled()
        } else {
            return StaticConfiguration(kind: kind, provider: Provider()) { entry in
                HabiscusWidgetEntryView(entry: entry)
                    .background()
                    .environment(\.managedObjectContext, dataController.container.viewContext)
            }.supportedFamilies([.systemSmall])
        }
    }
}

struct HabiscusWidget_Previews: PreviewProvider {
    static var previews: some View {
        Previewing(\.habit) { habit in
            let entry = SimpleEntry(habit: HabitEntity(habit: habit), date: Date())
            HabiscusWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}

/*#Preview(as: .systemSmall) {
    HabiscusWidget()
} timeline: {
    SimpleEntry(habit: HabitEntity.example, date: Date())
}*/

extension View {
     func widgetBackground(_ backgroundView: some View) -> some View {
         if #available(iOSApplicationExtension 17.0, *) {
             return containerBackground(for: .widget) {
                 backgroundView
             }
         } else {
             return background {
                 backgroundView
             }
         }
    }
}
