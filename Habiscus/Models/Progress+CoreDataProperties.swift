//
//  Progress+CoreDataProperties.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/19/23.
//
//

import Foundation
import CoreData


extension Progress {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Progress> {
        return NSFetchRequest<Progress>(entityName: "Progress")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var isSkipped: Bool
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var counts: NSSet?
    @NSManaged public var habit: Habit?
    
    public var wrappedDate: Date {
        date ?? Date.now
    }
    
    public var relatedGoal: Goal? {
        if let habit = habit {
            return habit.goal
        } else {
            return nil
        }
    }
    
    public var weekdayString: String {
        wrappedDate.currentWeekdayString
    }
    
    public var weekday: Weekday? {
        Weekday(rawValue: weekdayString.localizedLowercase)
    }

    public var wrappedLastUpdated: Date {
        lastUpdated ?? Date.now
    }

    public var countsArray: [Count] {
        let set = counts as? Set<Count> ?? []
        return set.sorted {
            $0.wrappedCreatedDate < $1.wrappedCreatedDate
        }
    }

    public var totalCount: Int {
        countsArray.map({Int($0.amount)}).reduce(0, +)
    }

    public var wrappedHabit: Habit {
        habit ?? Habit()
    }

    public func checkCompleted() -> Bool {
        totalCount >= wrappedHabit.goalNumber
    }

}

// MARK: Generated accessors for counts
extension Progress {

    @objc(addCountsObject:)
    @NSManaged public func addToCounts(_ value: Count)

    @objc(removeCountsObject:)
    @NSManaged public func removeFromCounts(_ value: Count)

    @objc(addCounts:)
    @NSManaged public func addToCounts(_ values: NSSet)

    @objc(removeCounts:)
    @NSManaged public func removeFromCounts(_ values: NSSet)

}

extension Progress : Identifiable {

}
