//
//  HabiscusAppIntents.swift
//  HabiscusAppIntents
//
//  Created by Skylar Clemens on 8/23/23.
//

import AppIntents

struct CompleteHabit: AppIntent {
    static var title: LocalizedStringResource = "Complete habit"
    
    @Parameter(title: "Habit")
    var habit: HabitEntity?
    
    @Parameter(title: "Date", requestValueDialog: IntentDialog("For which date?"))
    var date: Date?
    
    @MainActor
    func perform() async throws -> some ReturnsValue<HabitEntity> & ProvidesDialog & OpensIntent {
        if habit == nil {
            habit = try await $habit.requestDisambiguation(among: HabitEntity.defaultQuery.suggestedEntities(),
                                                           dialog: IntentDialog("Which habit?"))
        }
        if date == nil {
            date = try await $date.requestValue(IntentDialog("For which date?"))
        }
        
        guard let habit else {
            throw Error.notFound
        }

        let selectedHabit = try? HabitsManager.shared.findHabitByName(name: habit.name)
        
        guard let selectedHabit = selectedHabit else {
            throw Error.notFound
        }
        guard !selectedHabit.isArchived else {
            throw Error.habitArchived
        }
        
        let habitManager = HabitManager(habit: selectedHabit)
        habitManager.markHabitComplete(date: date)
        
        return .result(
            value: habit,
            opensIntent: OpenHabit(habit: $habit),
            dialog: "Okay, setting \(selectedHabit.wrappedName) to complete"
        )
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

struct OpenHabit: AppIntent {
    static var title: LocalizedStringResource = "Open Habit"
    static var description: IntentDescription = IntentDescription("This will open the habit in Habiscus", categoryName: "Navigation")
    
    @Parameter(title: "Habit")
    var habit: HabitEntity?
    
    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$habit)")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        guard let habit else {
            throw Error.notFound
        }
        do {
            let habitMatch = try HabitsManager.shared.findHabit(id: habit.id)
            Navigator.shared.goTo(habit: habitMatch)
            return .result()
        } catch let error {
            throw error
        }
    }
    
    static var openAppWhenRun: Bool = true
    
    enum Error: Swift.Error, CustomLocalizedStringResourceConvertible {
        case notFound

        var localizedStringResource: LocalizedStringResource {
            switch self {
                case .notFound: return "Habit not found"
            }
        }
    }
}
