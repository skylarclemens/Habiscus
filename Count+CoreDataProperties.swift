//
//  Count+CoreDataProperties.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/23/23.
//
//

import Foundation
import CoreData


extension Count {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Count> {
        return NSFetchRequest<Count>(entityName: "Count")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var count: Int16
    @NSManaged public var habit: Habit?
    
    public var wrappedCreatedDate: Date {
        createdAt ?? Date.now
    }
    
    public var wrappedCount: Int {
        Int(count)
    }
    
    public var createdDateString: String {
        createdAt?.formatted() ?? "Unknown date"
    }

}

extension Count : Identifiable {

}
