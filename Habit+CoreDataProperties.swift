//
//  Habit+CoreDataProperties.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/24/23.
//
//

import Foundation
import CoreData


extension Habit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Habit> {
        return NSFetchRequest<Habit>(entityName: "Habit")
    }

    @NSManaged public var created_at: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var color: String?
    @NSManaged public var counts: NSSet?
    
    public var wrappedName: String {
        name ?? "Unkown name"
    }
    
    public var formattedCreatedDate: String {
        created_at?.formatted(.dateTime.day().month().year()) ?? "Date not found"
    }
    
    public var countsArray: [Count] {
        let set = counts as? Set<Count> ?? []
        return set.sorted {
            $0.wrappedCreatedDate < $1.wrappedCreatedDate
        }
    }
    
    public var habitColor: String {
        color ?? "pink"
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
