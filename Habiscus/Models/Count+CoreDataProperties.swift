//
//  Count+CoreDataProperties.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/28/23.
//
//

import Foundation
import CoreData


extension Count {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Count> {
        return NSFetchRequest<Count>(entityName: "Count")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var amount: Int16
    @NSManaged public var progress: Progress?
    
    public var wrappedCreatedDate: Date {
        createdAt ?? Date.now
    }
    
    public var createdDateString: String {
        createdAt?.formatted() ?? "Unknown date"
    }

    public var wrappedDate: Date {
        date ?? Date.now
    }
    
    public var dateString: String {
        date?.formatted() ?? "Unknown date"
    }
}

extension Count : Identifiable {

}
