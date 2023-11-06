//
//  HabitIntent.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/6/23.
//

import AppIntents

struct WidgetHabitSelection: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Habit"
    static var description = IntentDescription("Select a habit to display")
    
    @Parameter(title: "Habit")
    var habit: HabitEntity
    
    init(habit: HabitEntity) {
        self.habit = habit
    }
    
    init() {}
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct AddCountToHabit: AppIntent {
    static var title: LocalizedStringResource = "Add count"
    
    @Parameter(title: "Habit")
    var habit: HabitEntity
    
    @Parameter(title: "Date")
    var date: Date
    
    @Parameter(title: "Amount")
    var amount: Int
    
    init(habit: HabitEntity, date: Date, amount: Int) {
        self.habit = habit
        self.date = date
        self.amount = amount
    }
    
    init() {}
    
    func perform() async throws -> some IntentResult {
        let selectedHabit = try? HabitsManager.shared.findHabitByName(name: habit.name)
        
        guard let selectedHabit = selectedHabit else {
            throw Error.notFound
        }
        guard !selectedHabit.isArchived else {
            throw Error.habitArchived
        }
        
        let habitManager = HabitManager(habit: selectedHabit)
        
        if let progress = selectedHabit.findProgress(from: date) {
            habitManager.addNewCount(progress: progress, date: date, amount: amount)
        } else {
            habitManager.addNewProgress(date: date, amount: amount)
        }
        
        return .result()
    }
    
    enum Error: Swift.Error, CustomLocalizedStringResourceConvertible {
        case notFound
        case habitArchived

        var localizedStringResource: LocalizedStringResource {
            switch self {
                case .notFound: return "Habit not found"
                case .habitArchived: return "Cannot change archived habit"
            }
        }
    }
}
