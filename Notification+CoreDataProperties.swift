//
//  Notification+CoreDataProperties.swift
//  HabiscusAppIntents
//
//  Created by Skylar Clemens on 8/23/23.
//
//

import Foundation
import CoreData


extension Notification {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notification> {
        return NSFetchRequest<Notification>(entityName: "Notification")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var scheduledDay: Int16
    @NSManaged public var time: Date?
    @NSManaged public var habit: Habit?
    
    public var wrappedDate: Date {
        createdAt ?? Date()
    }
    
    public var wrappedTime: Date {
        time ?? Date()
    }

}

extension Notification : Identifiable {

}
