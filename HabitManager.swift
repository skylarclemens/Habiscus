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
    
    func updateStreak(progress: Progress, date: Date, justCompleted: Bool) {
        if justCompleted {
            if let habit = progress.habit {
                let streaks = habit.streaksArray.filter({
                    dateWithinRange(date, start: $0.wrappedStartDate, finish: $0.wrappedLastDate)
                }).sorted(by: { $0.wrappedStartDate.compare($1.wrappedStartDate) == .orderedAscending })
                if streaks.count == 1 {
                    let streak = streaks[0]
                    streak.count += 1
                    streak.lastDate = date
                    print("count == 1 \(streaks)")
                } else if streaks.count > 1 {
                    print("count > 1 \(streaks)")
                    combineStreaks(streak1: streaks[0], streak2: streaks[1])
                } else {
                    print(streaks)
                    createNewStreak(habit: habit, date: date)
                }
            }
            return
        }
    }
    
    func undoStreak(progress: Progress, streak: Streak) {
        if streak.count == 1 {
            moc.delete(streak)
        } else {
            let updatedStreak = Streak(context: moc)
            updatedStreak.id = streak.id
            updatedStreak.count = streak.count - 1
            updatedStreak.startDate = streak.wrappedStartDate
            updatedStreak.lastDate = Calendar.current.date(byAdding: .day, value: -1, to: streak.wrappedLastDate)!
            updatedStreak.habit = streak.habit
            moc.delete(streak)
        }
    }
    
    func dateWithinLastDay(_ date:Date, of checkDate: Date) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: checkDate)
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: startOfDay)!
        let oneDayAfter = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        print("within range \(date >= oneDayAgo && date <= oneDayAfter)")
        return date >= oneDayAgo && date <= oneDayAfter
    }
    
    func dateWithinRange(_ date: Date, start: Date, finish: Date) -> Bool {
        print("start: \(start) finish: \(finish) checkingDay: \(date)")
        print("within last day \(dateWithinLastDay(date, of: start) || dateWithinLastDay(date, of: finish))")
        return dateWithinLastDay(date, of: start) || dateWithinLastDay(date, of: finish)
    }
    
    
    func createNewStreak(habit: Habit, date: Date) {
        print("New streak")
        let newStreak = Streak(context: moc)
        newStreak.id = UUID()
        newStreak.count = 1
        newStreak.startDate = date
        newStreak.lastDate = date
        newStreak.habit = habit
    }
    
    func combineStreaks(streak1: Streak, streak2: Streak) {
        let newStreak = Streak(context: moc)
        newStreak.id = UUID()
        newStreak.count = Int16(streak1.countNumber + streak2.countNumber + 1)
        newStreak.startDate = streak1.wrappedStartDate
        newStreak.lastDate = streak2.wrappedLastDate
        newStreak.habit = streak1.habit
        moc.delete(streak1)
        moc.delete(streak2)
        print("Combined streak")
        print(newStreak)
    }
    
    func addNewCount(progress: Progress, date: Date) {
        if Date.now.dateIsAfter(date) {
            return
        }
        progress.habit!.lastUpdated = Date.now
        print("before add: \(progress.totalCount)")
        progress.lastUpdated = Date.now
        let newCount = Count(context: moc)
        newCount.id = UUID()
        newCount.createdAt = Date.now
        newCount.date = Calendar.current.isDateInToday(date) ? Date.now : date
        newCount.progress = progress
        progress.addToCounts(newCount)
        progress.isCompleted = progress.totalCount >= progress.wrappedHabit.goalNumber
        print("after add: \(progress.totalCount)")
        let justCompleted = progress.totalCount == progress.wrappedHabit.goalNumber
        
        updateStreak(progress: progress, date: date, justCompleted: justCompleted)
        try? moc.save()
    }
    
    func addNewProgress(habit: Habit, date: Date) {
        if Date.now.dateIsAfter(date) {
            return
        }
        let newProgress = Progress(context: moc)
        newProgress.id = UUID()
        newProgress.date = date
        newProgress.isCompleted = habit.goalNumber == 1 ? true : false
        newProgress.lastUpdated = Date.now
        newProgress.habit = habit
        addNewCount(progress: newProgress, date: date)
    }
    
    func addNewProgressAndCount(date: Date) {
        if Date.now.dateIsAfter(date) {
            return
        }
        if let habit = managedHabit {
            addNewProgress(habit: habit, date: date)
        }
    }
    
    func undoLastCount(_ habit: Habit) {
        if let mostRecentCount = habit.mostRecentCount() {
            let lastUpdatedProgress = habit.lastUpdatedProgress()
            print("Progress count before: \(lastUpdatedProgress.totalCount)")
            habit.lastUpdatedProgress().removeFromCounts(mostRecentCount)
            moc.delete(mostRecentCount)
            /*if lastUpdatedProgress.isCompleted == true && lastUpdatedProgress.totalCount < habit.goalNumber {
                print("less")
                undoStreak(progress: lastUpdatedProgress, streak: <#T##Streak#>)
            }*/
            lastUpdatedProgress.isCompleted = lastUpdatedProgress.totalCount >= habit.goalNumber
            print("Progress count after: \(lastUpdatedProgress.totalCount)")
            habit.lastUpdated = Date.now
            try? moc.save()
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
