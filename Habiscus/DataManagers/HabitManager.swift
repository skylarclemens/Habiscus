//
//  HabitManager.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/28/23.
//

import Foundation
import CoreData
import UserNotifications
import WidgetKit

struct HabitManager {
    private let moc: NSManagedObjectContext
    private let managedHabit: Habit?
    
    init() {
        self.moc = DataController.shared.container.viewContext
        self.managedHabit = nil
    }
    
    init(habit: Habit) {
        self.moc = DataController.shared.container.viewContext
        self.managedHabit = habit
    }
    
    init(habit: Habit, context: NSManagedObjectContext) {
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
        WidgetCenter.shared.reloadTimelines(ofKind: "HabitWidget")
    }
    
    // Makes sure the date is today or earlier
    // Creates a new Progress entity and adds a new count
    func addNewProgress(habit: Habit? = nil, date: Date, skip: Bool = false, amount: Int? = 1) {
        guard !date.isAfter(Date()) else { return }
        guard let habit = getHabit(habit) else { return }
        
        var progressDate = date
        if habit.goalFrequency == "weekly" {
            if let existingProgress = habit.findProgress(from: date) {
                addNewCount(progress: existingProgress, date: date, habit: habit, amount: amount)
                return
            }
            progressDate = date.startOfWeek()
        }
        
        let newProgress = Progress(context: moc)
        newProgress.id = UUID()
        newProgress.date = progressDate
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
        
        var progressDate = date
        if habit.goalFrequency == "weekly" {
            if let existingProgress = habit.findProgress(from: date) {
                setProgressSkip(progress: existingProgress, skip: true)
                return
            }
            progressDate = date.startOfWeek()
        }
        
        let newProgress = Progress(context: moc)
        newProgress.id = UUID()
        newProgress.date = progressDate
        newProgress.lastUpdated = Date()
        newProgress.isCompleted = false
        newProgress.isSkipped = true
        newProgress.habit = habit
        habit.addToProgress(newProgress)
        habit.lastUpdated = Date()
        
        try? moc.save()
        WidgetCenter.shared.reloadTimelines(ofKind: "HabitWidget")
    }
    
    func setProgressSkip(_ habit: Habit? = nil, progress: Progress, skip: Bool) {
        guard let habit = getHabit(habit) else { return }
        progress.isSkipped = skip
        progress.lastUpdated = Date()
        habit.lastUpdated = Date()
        
        try? moc.save()
        WidgetCenter.shared.reloadTimelines(ofKind: "HabitWidget")
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
        WidgetCenter.shared.reloadTimelines(ofKind: "HabitWidget")
    }
    
    func undoAction(action: Action) {
        guard let progress = action.progress else { return }
        action.completed = false
        action.text = nil
        action.date = nil
        
        progress.isCompleted = progress.checkCompleted()
        
        progress.habit?.lastUpdated = Date()
        
        try? moc.save()
        WidgetCenter.shared.reloadTimelines(ofKind: "HabitWidget")
    }
    
    // TODO: Rewrite weekly code
    func markHabitComplete(_ habit: Habit? = nil, date: Date?) {
        guard let habit = getHabit(habit) else {
            return
        }
        let selectedDate = date ?? Date()
        var progressDate = selectedDate

        if let progress = habit.findProgress(from: selectedDate) {
            let currentCount = progress.totalCount
            let neededCounts = habit.goalNumber - currentCount
            addNewCount(progress: progress, date: selectedDate, habit: habit, amount: neededCounts)
        } else {
            addNewProgress(date: selectedDate, amount: habit.goalNumber)
        }
        
        try? moc.save()
    }
    
    func archiveHabit(_ habit: Habit? = nil) throws {
        guard let habit = getHabit(habit) else {
            return
        }
        habit.isArchived = true
        removeAllNotifications(habit)
        do {
            try moc.save()
        } catch let error {
            print(error.localizedDescription)
        }
        WidgetCenter.shared.reloadTimelines(ofKind: "HabitWidget")
    }
    
    func unarchiveHabit(_ habit: Habit? = nil) throws {
        guard let habit = getHabit(habit) else {
            return
        }
        habit.isArchived = false
        try? moc.save()
        WidgetCenter.shared.reloadTimelines(ofKind: "HabitWidget")
    }
    
    func removeHabit(_ habit: Habit? = nil) throws {
        guard let habit = getHabit(habit) else {
            return
        }
        removeAllNotifications(habit)
        moc.delete(habit)
        try? moc.save()
        WidgetCenter.shared.reloadTimelines(ofKind: "HabitWidget")
    }
    
    func removeHabit(_ habit: Habit? = nil, toastManager: ToastManager) throws {
        guard let habit = getHabit(habit) else {
            return
        }
        toastManager.successTitle = "\(habit.wrappedName) has been deleted"
        removeAllNotifications(habit)
        moc.delete(habit)
        do {
            try moc.save()
            toastManager.isSuccess = true
            toastManager.showAlert = true
            HapticManager.shared.simpleSuccess()
        } catch let error {
            print(error.localizedDescription)
            toastManager.errorMessage = "Error while deleting"
            toastManager.isSuccess = false
            toastManager.showAlert = true
            HapticManager.shared.simpleError()
        }
        WidgetCenter.shared.reloadTimelines(ofKind: "HabitWidget")
    }
    
    func removeAllNotifications(_ habit: Habit? = nil) {
        guard let habit = getHabit(habit) else {
            return
        }
        if habit.notificationsArray.count > 0 {
            let notificationsIds = habit.notificationsArray.map { $0.id!.uuidString }
            NotificationManager.shared.removeNotifications(notificationsIds)
            habit.notificationsArray.forEach {
                moc.delete($0)
            }
            try? moc.save()
        }
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
