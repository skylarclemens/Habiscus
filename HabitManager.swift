//
//  HabitManager.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/28/23.
//

import Foundation
import CoreData

struct HabitManager {
    private let moc: NSManagedObjectContext
    private let managedHabit: Habit?
    
    init(context: NSManagedObjectContext) {
        self.moc = context
        self.managedHabit = nil
    }
    
    init(context: NSManagedObjectContext, habit: Habit) {
        self.moc = context
        self.managedHabit = habit
    }
    
    func addNewCount(progress: Progress, date: Date) {
        progress.habit!.lastUpdated = Date.now
        progress.totalCount += 1
        progress.isCompleted = progress.totalCount >= progress.wrappedHabit.goalNumber
        progress.lastUpdated = Date.now
        let newCount = Count(context: moc)
        newCount.id = UUID()
        newCount.createdAt = Date.now
        newCount.date = Calendar.current.isDateInToday(date) ? Date.now : date
        newCount.progress = progress
        try? moc.save()
    }
    
    func addNewProgress(habit: Habit, date: Date) {
        let newProgress = Progress(context: moc)
        newProgress.id = UUID()
        newProgress.date = date
        newProgress.isCompleted = habit.goalNumber == 1 ? true : false
        newProgress.lastUpdated = Date.now
        newProgress.totalCount = 0
        newProgress.habit = habit
        addNewCount(progress: newProgress, date: date)
    }
    
    func addNewProgressAndCount(date: Date) {
        if let habit = managedHabit {
            addNewProgress(habit: habit, date: date)
        }
    }
    
    func undoLastCount(_ habit: Habit) {
        if let mostRecentCount = habit.mostRecentCount() {
            print(mostRecentCount)
            moc.delete(mostRecentCount)
            habit.lastUpdated = Date.now
            try? moc.save()
            return
        }
    }
    
    func undoLastCount() {
        if let habit = managedHabit {
            undoLastCount(habit)
        }
    }
    
    func removeHabit(_ habit: Habit) {
        moc.delete(habit)
        try? moc.save()
    }
    
    func removeHabit() {
        if let habit = managedHabit {
            removeHabit(habit)
        }
    }
}
