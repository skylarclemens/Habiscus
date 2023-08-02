//
//  Habit+CoreDataProperties.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/29/23.
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
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var progress: NSSet?
    @NSManaged public var lastUpdated: Date?
    
    public var wrappedName: String {
        name ?? "Unkown name"
    }
    
    public var createdDate: Date {
            createdAt ?? Date()
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
    
    // Compares day the habit was first created and day since first progress to find starting day
    // Divides total completed progress count over number of days since each day has one progress object
    // Returns percentage
    public var successPercentage: Double {
        let daysSinceCreated = abs(self.createdDate.daysBetween(Date()) ?? 0)
        let daysSinceFirstProgress = abs(self.progressArray.first?.wrappedDate.daysBetween(Date()) ?? 0)
        let progressDays = max(daysSinceCreated, daysSinceFirstProgress)
        
        let completedProgress = progressArray.filter { $0.isCompleted }.count
        
        return (Double(completedProgress) / Double(max(progressDays, 1))) * 100
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
    
    public func mostRecentCount() -> Count? {
        let progress = lastUpdatedProgress()
        
        if progress.countsArray.count > 0 {
            return progress.countsArray.reduce(progress.countsArray[0], {
                $0.wrappedCreatedDate > $1.wrappedCreatedDate ? $0 : $1
            })
        }
        return nil
    }
    
    // Starts progress array at most recent, assumed that progress is array is already sorted
    // If first progress is not completed or is more than one day from today, returns a streak of 0
    // Returns first, most recent, streak of streak array
    public func getCurrentStreak() -> Int {
        guard let latestProgress = progressArray.last,
              latestProgress.isCompleted,
              !Date().isMoreThanOneDayFrom(latestProgress.wrappedDate) else {
            return 0
        }

        let streaks = calculateStreaksArray(from: progressArray.reversed())
        return streaks.first ?? 0
    }
    
    // Adds to streak if compared dates are completed and one day apart
    // Returns array of all streaks
    public func calculateStreaksArray(from: [Progress]? = nil) -> [Int] {
        let refArray: [Progress] = from ?? self.progressArray
        var streakArray: [Int] = []
        var streak = 0
        
        for (progress, refProgress) in zip(refArray.dropFirst(), refArray) {
            if progress.isCompleted, refProgress.isCompleted, abs(progress.wrappedDate.daysBetween(refProgress.wrappedDate) ?? 0) == 1 {
                streak += 1
            } else {
                if streak > 0 || refProgress.isCompleted {
                    streakArray.append(streak + 1)
                }
                streak = 0
            }
        }
        
        if streak > 0 || (refArray.last?.isCompleted ?? false) {
            streakArray.append(streak + 1)
        }
        
        return streakArray
    }
    
    // Gets the highest number in the streak array
    public func getLongestStreak() -> Int {
        calculateStreaksArray().max() ?? 0
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
