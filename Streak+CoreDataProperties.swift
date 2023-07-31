//
//  Streak+CoreDataProperties.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/29/23.
//
//

import Foundation
import CoreData


extension Streak {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Streak> {
        return NSFetchRequest<Streak>(entityName: "Streak")
    }

    @NSManaged public var count: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var lastDate: Date?
    @NSManaged public var startDate: Date?
    @NSManaged public var habit: Habit?
    
    public var wrappedStartDate: Date {
        startDate ?? Date.now
    }
    
    public var wrappedLastDate: Date {
        lastDate ?? Date.now
    }
    
    public var countNumber: Int {
        Int(count)
    }

}

extension Streak : Identifiable {

}
