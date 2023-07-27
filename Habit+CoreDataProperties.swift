//
//  Habit+CoreDataProperties.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/26/23.
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
    @NSManaged public var counts: NSSet?

    public var wrappedName: String {
        name ?? "Unkown name"
    }
    
    public var formattedCreatedDate: String {
        createdAt?.formatted(.dateTime.day().month().year()) ?? "Date not found"
    }
    
    public var countsArray: [Count] {
        let set = counts as? Set<Count> ?? []
        return set.sorted {
            $0.wrappedCreatedDate < $1.wrappedCreatedDate
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
    
    public func findGoalCount(on date: Date) -> Int {
        let currentGoalCounts = self.countsArray.filter {
            let daysBetween = $0.wrappedDate.daysBetweenDates(to: date)!
            return abs(daysBetween) <= self.goalFrequencyNumber - 1
        }
        return currentGoalCounts.count
    }
}

// MARK: Generated accessors for counts
extension Habit {

    @objc(addCountsObject:)
    @NSManaged public func addToCounts(_ value: Count)

    @objc(removeCountsObject:)
    @NSManaged public func removeFromCounts(_ value: Count)

    @objc(addCounts:)
    @NSManaged public func addToCounts(_ values: NSSet)

    @objc(removeCounts:)
    @NSManaged public func removeFromCounts(_ values: NSSet)

}

extension Habit : Identifiable {

}
