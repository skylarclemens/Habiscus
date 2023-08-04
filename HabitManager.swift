//
//  HabitManager.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/28/23.
//

import Foundation
import CoreData
import UserNotifications

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
    
    // Makes sure the date is today or earlier
    // Creates a new count and adds it to progress
    func addNewCount(progress: Progress, date: Date) {
        guard !date.isAfter(Date()) else {
            return
        }
        
        let newCount = Count(context: moc)
        newCount.id = UUID()
        newCount.createdAt = Date()
        newCount.date = Calendar.current.isDateInToday(date) ? Date() : date
        newCount.progress = progress
        progress.addToCounts(newCount)
        
        updateProgress(progress)
        try? moc.save()
    }
    
    // Makes sure the date is today or earlier
    // Creates a new Progress entity and adds a new count
    func addNewProgress(habit: Habit? = nil, date: Date) {
        guard !date.isAfter(Date()) else {
            return
        }
        guard let habit = getHabit(habit) else {
            return
        }
        let newProgress = Progress(context: moc)
        newProgress.id = UUID()
        newProgress.date = date
        newProgress.isCompleted = habit.goalNumber == 1 ? true : false
        newProgress.lastUpdated = Date()
        newProgress.habit = habit
        habit.addToProgress(newProgress)
        
        addNewCount(progress: newProgress, date: date)
    }
    
    func undoLastCount(_ habit: Habit? = nil, from date: Date) {
        guard let habit = getHabit(habit),
              let mostRecentCount = habit.mostRecentCount(from: date),
              let currentProgress = mostRecentCount.progress else {
            return
        }
        currentProgress.removeFromCounts(mostRecentCount)
        moc.delete(mostRecentCount)
        
        currentProgress.isCompleted = currentProgress.checkCompleted()
        
        habit.lastUpdated = Date()
        
        try? moc.save()
    }
    
    func removeHabit(_ habit: Habit? = nil) {
        guard let habit = getHabit(habit) else {
            return
        }
        moc.delete(habit)
        try? moc.save()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habit.id!.uuidString])
    }
    
    // MARK: - Private methods
    
    private func updateProgress(_ progress: Progress) {
        progress.habit?.lastUpdated = Date()
        progress.lastUpdated = Date()
        progress.isCompleted = progress.checkCompleted()
    }
    
    private func getHabit(_ habit: Habit?) -> Habit? {
        return habit ?? managedHabit
    }
}
