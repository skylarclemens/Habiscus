//
//  Previewing.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/19/23.
//
// Based off of code from Andy Nadal
// https://github.com/andynadal/swiftui-coredata-previews

import SwiftUI
import CoreData

struct Previewing<Content: View, Model>: View {
    var content: Content
    var dataController: DataController
    
    init(_ keyPath: KeyPath<PreviewData, (NSManagedObjectContext) -> Model>, @ViewBuilder content: (Model) -> Content) {
        self.dataController = DataController(inMemory: true)
        let data = PreviewData()
        let generateData = data[keyPath: keyPath](dataController.container.viewContext)
        
        self.content = content(generateData)
    }
    
    init(withData keyPath: KeyPath<PreviewData, (NSManagedObjectContext) -> Model>, @ViewBuilder content: () -> Content) {
        self.dataController = DataController(inMemory: true)
        let data = PreviewData()
        let _ = data[keyPath: keyPath](dataController.container.viewContext)
        
        self.content = content()
    }
    
    var body: some View {
        content
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}

struct PreviewData {
    var habit: (NSManagedObjectContext) -> Habit {
        { context in
            let habit = Habit(context: context)
            habit.id = UUID()
            habit.name = "Test"
            habit.icon = "🤩"
            habit.color = "blue"
            habit.createdAt = Date.now
            habit.startDate = Date()
            habit.endDate = nil
            habit.isArchived = false
            habit.goal = 1
            habit.unit = "count"
            habit.interval = 1
            habit.frequency = "daily"
            habit.weekdays = "Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday"
            habit.customCount = true
            habit.defaultCount = 2
            
            let count = Count(context: context)
            count.id = UUID()
            count.createdAt = Date()
            count.date = Date()
            
            let progress = Progress(context: context)
            progress.id = UUID()
            progress.date = Date()
            progress.isCompleted = true
            progress.isSkipped = false
            
            progress.addToCounts(count)
            habit.addToProgress(progress)
            
            return habit
        }
    }
    
    var habitWithActions: (NSManagedObjectContext) -> Habit {
        { context in
            let habit = Habit(context: context)
            habit.id = UUID()
            habit.name = "Test"
            habit.icon = "🤩"
            habit.color = "blue"
            habit.createdAt = Date.now
            habit.startDate = Date()
            habit.endDate = nil
            habit.isArchived = false
            habit.goal = 1
            habit.unit = "count"
            habit.interval = 1
            habit.frequency = "daily"
            habit.weekdays = "Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday"
            habit.progressMethod = "actions"
            
            let timerAction = Action(context: context)
            timerAction.type = "timer"
            timerAction.order = 0
            timerAction.number = 60
            habit.addToActions(timerAction)
            
            let emotionAction = Action(context: context)
            emotionAction.type = "emotion"
            emotionAction.order = 1
            habit.addToActions(emotionAction)
            
            let progressTimerAction = Action(context: context)
            progressTimerAction.type = "timer"
            progressTimerAction.order = 0
            progressTimerAction.number = 60
            progressTimerAction.completed = true
            progressTimerAction.date = Date()
            progressTimerAction.progress
            
            let progressEmotionAction = Action(context: context)
            progressEmotionAction.type = "emotion"
            progressEmotionAction.order = 1
            
            let progress = Progress(context: context)
            progress.id = UUID()
            progress.date = Date()
            progress.isCompleted = true
            progress.isSkipped = false
            progress.habit = habit
            progress.addToActions(progressTimerAction)
            progress.addToActions(progressEmotionAction)
            
            return habit
        }
    }
    
    var habits: (NSManagedObjectContext) -> [Habit] {
        { context in
            var previewHabits: [Habit] = []
            for _ in 0..<3 {
                let habit = Habit(context: context)
                habit.id = UUID()
                habit.name = "Test"
                habit.icon = "🤩"
                habit.color = "blue"
                habit.createdAt = Date.now
                habit.startDate = Date()
                habit.endDate = nil
                habit.isArchived = false
                habit.goal = 1
                habit.unit = "count"
                habit.interval = 1
                habit.frequency = "daily"
                habit.weekdays = "Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday"
                
                let count = Count(context: context)
                count.id = UUID()
                count.createdAt = Date()
                count.date = Date()
                
                let progress = Progress(context: context)
                progress.id = UUID()
                progress.date = Date()
                progress.isCompleted = true
                progress.isSkipped = false
                
                progress.addToCounts(count)
                habit.addToProgress(progress)
                
                previewHabits.append(habit)
            }
            return previewHabits
        }
    }
    
    var newHabit: (NSManagedObjectContext) -> Habit {
        { context in
            return Habit(context: context)
        }
    }
    
    var timerAction: (NSManagedObjectContext) -> Action {
        { context in
            let action = Action(context: context)
            action.type = "Timer"
            action.number = 30
            action.order = 0
            
            return action
        }
    }
}
