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
    @NSManaged public var streaks: NSSet?
    @NSManaged public var lastUpdated: Date?
    
    public var wrappedName: String {
        name ?? "Unkown name"
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
        lastUpdated ?? Date.now
    }
    
    public var streaksArray: [Streak] {
        let set = streaks as? Set<Streak> ?? []
        return set.sorted {
            $0.wrappedStartDate < $1.wrappedStartDate
        }
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
    
    public func mostRecentCount() -> Count? {
        let progress = lastUpdatedProgress()
        
        if progress.countsArray.count > 0 {
            return progress.countsArray.reduce(progress.countsArray[0], {
                $0.wrappedCreatedDate > $1.wrappedCreatedDate ? $0 : $1
            })
        }
        return nil
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

// MARK: Generated accessors for streaks
extension Habit {

    @objc(addStreaksObject:)
    @NSManaged public func addToStreaks(_ value: Streak)

    @objc(removeStreaksObject:)
    @NSManaged public func removeFromStreaks(_ value: Streak)

    @objc(addStreaks:)
    @NSManaged public func addToStreaks(_ values: NSSet)

    @objc(removeStreaks:)
    @NSManaged public func removeFromStreaks(_ values: NSSet)

}

extension Habit : Identifiable {

}
