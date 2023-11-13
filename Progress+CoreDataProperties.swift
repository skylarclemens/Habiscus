//
//  Progress+CoreDataProperties.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/10/23.
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
    @NSManaged public var actions: NSSet?
    
    public var wrappedDate: Date {
        date ?? Date.now
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
    
    public var actionsArray: [Action] {
        let set = actions as? Set<Action> ?? []
        return set.sorted {
            $0.order < $1.order
        }
    }
    
    public var totalCount: Int {
        if habit?.wrappedProgressMethod == .counts {
            countsArray.map({Int($0.amount)}).reduce(0, +)
        } else {
            actionsArray.filter { $0.completed }.count
        }
    }
    
    public var wrappedHabit: Habit {
        habit ?? Habit()
    }
    
    public func checkCompleted() -> Bool {
        totalCount >= wrappedHabit.goalNumber
    }
    
    public var isEmpty: Bool {
        countsArray.count == 0
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

// MARK: Generated accessors for actions
extension Progress {
    
    @objc(addActionsObject:)
    @NSManaged public func addToActions(_ value: Action)
    
    @objc(removeActionsObject:)
    @NSManaged public func removeFromActions(_ value: Action)
    
    @objc(addActions:)
    @NSManaged public func addToActions(_ values: NSSet)
    
    @objc(removeActions:)
    @NSManaged public func removeFromActions(_ values: NSSet)
    
}

extension Progress : Identifiable {
    
}
