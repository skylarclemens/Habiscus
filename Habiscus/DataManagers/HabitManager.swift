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
    func addNewCount(progress: Progress, date: Date, habit: Habit? = nil, amount: Int? = 1) {
        guard !date.isAfter(Date()) else { return }
        
        let newCount = Count(context: moc)
        newCount.id = UUID()
        newCount.createdAt = Date()
        newCount.date = Calendar.current.isDateInToday(date) ? Date() : date
        newCount.progress = progress
        newCount.amount = Int16(amount ?? 1)
        progress.addToCounts(newCount)
        
        updateProgress(progress)
        try? moc.save()
    }
    
    // Makes sure the date is today or earlier
    // Creates a new Progress entity and adds a new count
    // Returns whether the progress was just completed or not
    func addNewProgress(habit: Habit? = nil, date: Date, skip: Bool = false, amount: Int? = 1) {
        guard !date.isAfter(Date()) else { return }
        guard let habit = getHabit(habit) else { return }
        let newProgress = Progress(context: moc)
        newProgress.id = UUID()
        newProgress.date = date
        newProgress.lastUpdated = Date()
        newProgress.isCompleted = amount! >= habit.goalNumber
        newProgress.isSkipped = skip
        newProgress.habit = habit
        habit.addToProgress(newProgress)
        
        if skip { return }
        
        addNewCount(progress: newProgress, date: date, habit: habit, amount: amount)
    }
    
    func addNewSkippedProgress(habit: Habit? = nil, date: Date) {
        guard let habit = getHabit(habit) else { return }
        let newProgress = Progress(context: moc)
        newProgress.id = UUID()
        newProgress.date = date
        newProgress.lastUpdated = Date()
        newProgress.isCompleted = false
        newProgress.isSkipped = true
        newProgress.habit = habit
        habit.addToProgress(newProgress)
        habit.lastUpdated = Date()
        
        try? moc.save()
    }
    
    func setProgressSkip(_ habit: Habit? = nil, progress: Progress, skip: Bool) {
        guard let habit = getHabit(habit) else { return }
        progress.isSkipped = skip
        progress.lastUpdated = Date()
        habit.lastUpdated = Date()
        
        try? moc.save()
    }
    
    func skipNewProgress(_ habit: Habit? = nil, on date: Date) {
        guard let habit = getHabit(habit) else { return }
        addNewSkippedProgress(habit: habit, date: date)
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
    
    func archiveHabit(_ habit: Habit? = nil) {
        guard let habit = getHabit(habit) else {
            return
        }
        habit.isArchived = true
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habit.id!.uuidString])
        try? moc.save()
    }
    
    func removeHabit(_ habit: Habit? = nil) {
        guard let habit = getHabit(habit) else {
            return
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habit.id!.uuidString])
        moc.delete(habit)
        try? moc.save()
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
