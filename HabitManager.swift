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
    
    func addNewCount(_ habit: Habit, date: Date) {
        let newCount = Count(context: moc)
        newCount.id = UUID()
        newCount.count += 1
        newCount.createdAt = Date.now
        newCount.date = Calendar.current.isDateInToday(date) ? Date.now : date
        newCount.habit = habit
        habit.addToCounts(newCount)
        try? moc.save()
    }
    
    func addNewCount(date: Date) {
        if let habit = managedHabit {
            addNewCount(habit, date: date)
        }
    }
    
    func undoLastCount(_ habit: Habit) {
        if habit.countsArray.count > 0 {
            let mostRecentCount = habit.countsArray.reduce(habit.countsArray[0], {
                $0.wrappedCreatedDate > $1.wrappedCreatedDate ? $0 : $1
            })
            habit.removeFromCounts(mostRecentCount)
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
