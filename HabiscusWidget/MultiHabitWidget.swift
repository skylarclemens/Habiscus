//
//  MultiHabitWidget.swift
//  HabiscusWidgetExtension
//
//  Created by Skylar Clemens on 1/29/24.
//

import WidgetKit
import SwiftUI
import CoreData

struct MultiHabitEntry: TimelineEntry {
    var habits: [HabitEntity]?
    public let date: Date
    
    static var placeholder: Self {
        Self(habits: [HabitEntity.example, HabitEntity.example2, HabitEntity.example3], date: .now)
    }
}

struct MultiHabitIntentProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> MultiHabitEntry {
        MultiHabitEntry.placeholder
    }
    
    func snapshot(for configuration: WidgetMultiHabitSelection, in context: Context) async -> MultiHabitEntry {
        let ids = configuration.habits.map { $0.id }
        let habits = try? HabitsManager.shared.findHabits(for: ids, refresh: true)
        if let habits {
            var habitEntities: [HabitEntity] = []
            for habit in habits {
                let habitEntity = HabitEntity(habit: habit)
                habitEntities.append(habitEntity)
            }
            return MultiHabitEntry(habits: habitEntities, date: .now)
        }
        return MultiHabitEntry.placeholder
    }
    
    func timeline(for configuration: WidgetMultiHabitSelection, in context: Context) async -> Timeline<MultiHabitEntry> {
        let ids = configuration.habits.map { $0.id }
        let habits = try? HabitsManager.shared.findHabits(for: ids, refresh: true)
        
        var entries: [MultiHabitEntry] = []
        if let habits {
            var habitEntities: [HabitEntity] = []
            for habit in habits {
                let habitEntity = HabitEntity(habit: habit)
                habitEntities.append(habitEntity)
            }
            let entry = MultiHabitEntry(habits: habitEntities, date: .now)
            entries.append(entry)
        }
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)
        return Timeline(entries: entries, policy: .after(startOfTomorrow ?? Date()))
    }
}

struct MultiHabitProvider: TimelineProvider {
    func placeholder(in context: Context) -> MultiHabitEntry {
        MultiHabitEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (MultiHabitEntry) -> ()) {
        do {
            guard let habits = try HabitsManager.shared.getAllActiveHabits() else {
                completion(.placeholder)
                return
            }
            
            var habitEntities: [HabitEntity] = []
            let habitSlice = habits[0..<4]
            for habit in habitSlice {
                let habitEntity = HabitEntity(habit: habit)
                habitEntities.append(habitEntity)
            }
            
            let entry = MultiHabitEntry(habits: habitEntities, date: .now)
            completion(entry)
        } catch {
            print(error)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        do {
            guard let habits = try HabitsManager.shared.getAllActiveHabits() else {
                completion(.init(entries: [], policy: .never))
                return
            }
            var habitEntities: [HabitEntity] = []
            var entries: [MultiHabitEntry] = []

            let entryDate: Date = .now
            let habitSlice = habits[0..<4]
            for habit in habitSlice {
                let habitEntity = HabitEntity(habit: habit)
                habitEntities.append(habitEntity)
            }
            
            let entry = MultiHabitEntry(habits: habitEntities, date: entryDate)
            entries.append(entry)
            
            let startOfToday = Calendar.current.startOfDay(for: Date())
            let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)
            let timeline = Timeline(entries: entries, policy: .after(startOfTomorrow ?? Date()))
            completion(timeline)
        } catch {
            print(error)
        }
    }
}

struct MultiHabitWidgetEntryView : View {
    var entry: MultiHabitProvider.Entry

    var body: some View {
        VStack {
            if let habits = entry.habits {
                SmallMultiHabitView(habits: habits)
            }
        }
    }
}

struct MultiHabitWidget: Widget {
    let dataController = DataController.shared
    let kind: String = "Multi Habit Widget"

    var body: some WidgetConfiguration {
        makeWidgetConfiguration()
            .configurationDisplayName("Multiple Habits")
            .description("Keep track of multiple habits.")
    }
    
    func makeWidgetConfiguration() -> some WidgetConfiguration {
        if #available(iOS 17.0, *) {
            return AppIntentConfiguration(kind: kind,
                                          intent: WidgetMultiHabitSelection.self,
                                          provider: MultiHabitIntentProvider()) { entry in
                MultiHabitWidgetEntryView(entry: entry)
                    .padding()
            }.supportedFamilies([.systemSmall])
                .contentMarginsDisabled()
        } else {
            return StaticConfiguration(kind: kind, provider: MultiHabitProvider()) { entry in
                MultiHabitWidgetEntryView(entry: entry)
                    .background()
                    .environment(\.managedObjectContext, dataController.container.viewContext)
            }.supportedFamilies([.systemSmall])
        }
    }
}

struct MultiHabitWidget_Previews: PreviewProvider {
    static var previews: some View {
        Previewing(\.habit) { habit in
            let entry = MultiHabitEntry(habits: [HabitEntity(habit: habit)], date: Date())
            MultiHabitWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
