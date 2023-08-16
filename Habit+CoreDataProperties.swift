//
//  Habit+CoreDataProperties.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/9/23.
//
//

import Foundation
import CoreData
import SwiftUI

extension Habit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Habit> {
        return NSFetchRequest<Habit>(entityName: "Habit")
    }

    @NSManaged public var color: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var goal: Int16
    @NSManaged public var goalFrequency: Int16
    @NSManaged public var metric: String?
    @NSManaged public var weekdays: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isArchived: Bool
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var name: String?
    @NSManaged public var icon: String?
    @NSManaged public var progress: NSSet?

    public var wrappedName: String {
        name ?? "Unkown name"
    }

    public var createdDate: Date {
        createdAt ?? Date()
    }
    
    public var goalMetric: String {
        metric ?? ""
    }
    
    public var emojiIcon: String {
        icon ?? ""
    }
    
    public var weekdaysStrings: [String] {
        let weekdaysComponents = weekdays?.components(separatedBy: ",")
        return weekdaysComponents?.compactMap { $0.trimmingCharacters(in: .whitespaces) } ?? []
        
    }
    
    public var weekdaysArray: [Weekday] {
        weekdaysStrings.compactMap { Weekday(rawValue: $0.localizedLowercase) ?? nil }
    }

    public var formattedCreatedDate: String {
        createdAt?.formatted(.dateTime.day().month().year()) ?? "Date not found"
    }

    public var progressArray: [Progress] {
        let set = progress as? Set<Progress> ?? []
        return set.sorted {
            $0.wrappedDate < $1.wrappedDate
        }
    }
    
    //Filter for progress that is not skipped
    public var activeProgressArray: [Progress] {
        progressArray.filter {
            !$0.isSkipped && !$0.countsArray.isEmpty
        }
    }

    public var lastUpdatedDate: Date {
        lastUpdated ?? Date()
    }

    public var habitColor: Color {
        Color(color ?? "pink")
    }

    public var goalNumber: Int {
        Int(goal)
    }

    public var goalFrequencyNumber: Int {
        Int(goalFrequency)
    }

    public var goalFrequencyString: String {
        goalFrequency == 1 ? "Daily" : "Weekly"
    }


    public var allCountsArray: [Count] {
        var tempCountArray: [Count] = []
        progressArray.forEach { item in
            item.countsArray.forEach { count in
                tempCountArray.append(count)
            }
        }
        return tempCountArray
    }

    public func findProgress(from date: Date) -> Progress? {
        if let progressObjects = self.progress?.allObjects as? [Progress],
            let progressOnDate = progressObjects.first(where: {
            Calendar.current.isDate($0.wrappedDate, inSameDayAs: date)
        }) {
            return progressOnDate
        }
        return nil
    }

    public func lastUpdatedProgress() -> Progress {
        return self.progressArray.reduce(self.progressArray[0], {
            $0.wrappedLastUpdated > $1.wrappedLastUpdated ? $0 : $1
        })
    }

    public func mostRecentCount(from date: Date) -> Count? {
        guard let progress = findProgress(from: date) else {
            return nil
        }
        
        if progress.countsArray.count > 0 {
            return progress.countsArray.reduce(progress.countsArray[0], {
                $0.wrappedCreatedDate > $1.wrappedCreatedDate ? $0 : $1
            })
        }
        return nil
    }
    
    // Compares day the habit was first created and day since first progress to find starting day
    // Divides total completed progress count over number of days since each day has one progress object
    // Returns percentage
    public var successPercentage: Double {
        let daysSinceCreated = abs(self.createdDate.daysBetween(Date()) ?? 0)
        let daysSinceFirstProgress = abs(self.activeProgressArray.first?.wrappedDate.daysBetween(Date()) ?? 0)
        let progressDays = max(daysSinceCreated, daysSinceFirstProgress)
        
        let completedProgress = activeProgressArray.filter { $0.isCompleted }.count
        
        return (Double(completedProgress) / Double(progressDays + 1)) * 100
    }

    // Starts progress array at most recent, assumed that progress is array is already sorted
    // If first progress is not completed or is more than one day from today, returns a streak of 0
    // Returns first, most recent, streak of streak array
    public func getCurrentStreak() -> Int {
        guard let mostRecentProgress = progressArray.last(where: { $0.isCompleted && !$0.isSkipped }) else {
            return 0
        }
        let closestProgress = self.findProgress(from: Date().closestPreviousWeekday(in: self.weekdaysArray)!)

        var streaks: [Int] = []
        if Calendar.current.isDateInToday(mostRecentProgress.wrappedDate) || (closestProgress?.isCompleted ?? false) {
            streaks = calculateStreaksArray(from: progressArray.reversed(), onDays: self.weekdaysArray)
        }
        return streaks.first ?? 0
    }

    // Adds to streak if compared dates are completed and proper length apart
    // Returns array of all streaks
    public func calculateStreaksArray(from: [Progress]? = nil, onDays daysToCheck: [Weekday]) -> [Int] {
        let refArray: [Progress] = from ?? self.progressArray
        var streakArray: [Int] = []
        var streak = 0
        
        for (progress, refProgress) in zip(refArray.dropFirst(), refArray) {
            if let progressWeekday = progress.weekday, let refProgressWeekday = refProgress.weekday {
                if !daysToCheck.contains(progressWeekday) || !daysToCheck.contains(refProgressWeekday) { continue }
            }
            if refProgress.isSkipped { continue }
            
            var isRefNextWeekdayDate: Bool = false
            if let findWeekdayDate = progress.wrappedDate.findWeekdayDate(in: daysToCheck, direction: .forward) {
                isRefNextWeekdayDate = Calendar.current.isDate(findWeekdayDate, inSameDayAs: refProgress.wrappedDate)
            }
            
            if progress.isSkipped && refProgress.isCompleted && isRefNextWeekdayDate {
                streak += 1
            } else if progress.isCompleted && refProgress.isCompleted && isRefNextWeekdayDate {
                streak += 1
            } else {
                if streak > 0 || refProgress.isCompleted {
                    streakArray.append(streak + 1)
                }
                streak = 0
            }
        }
        
        if let lastProgress = refArray.last,
           let lastProgressWeekday = lastProgress.weekday,
           daysToCheck.contains(lastProgressWeekday) && lastProgress.isCompleted && !lastProgress.isSkipped {
            streakArray.append(streak + 1)
        } else if streak > 0 {
            streakArray.append(streak)
        }
        
        return streakArray
    }

    // Gets the highest number in the streak array
    public func getLongestStreak() -> Int {
        calculateStreaksArray(from: progressArray.reversed(), onDays: self.weekdaysArray).max() ?? 0
    }
    
}

// MARK: Generated accessors for progress
extension Habit {

    @objc(addProgressObject:)
    @NSManaged public func addToProgress(_ value: Progress)

    @objc(removeProgressObject:)
    @NSManaged public func removeFromProgress(_ value: Progress)

    @objc(addProgress:)
    @NSManaged public func addToProgress(_ values: NSSet)

    @objc(removeProgress:)
    @NSManaged public func removeFromProgress(_ values: NSSet)

}

extension Habit : Identifiable {

}
