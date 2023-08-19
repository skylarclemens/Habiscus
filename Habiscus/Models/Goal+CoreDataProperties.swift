//
//  Goal+CoreDataProperties.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/19/23.
//
//

import Foundation
import CoreData


extension Goal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Goal> {
        return NSFetchRequest<Goal>(entityName: "Goal")
    }

    @NSManaged public var amount: Int16
    @NSManaged public var unit: String?
    @NSManaged public var interval: Int16
    @NSManaged public var frequency: String?
    @NSManaged public var weekdays: String?
    @NSManaged public var habit: Habit?
    
    public var wrappedUnit: String {
        unit ?? ""
    }
    
    public var wrappedFrequency: String {
        frequency ?? ""
    }
    
    public var weekdaysStrings: [String] {
        let weekdaysComponents = weekdays?.components(separatedBy: ",")
        return weekdaysComponents?.compactMap { $0.trimmingCharacters(in: .whitespaces) } ?? []
        
    }
    
    public var weekdaysArray: [Weekday] {
        weekdaysStrings.compactMap { Weekday(rawValue: $0.localizedLowercase) ?? nil }
    }
}

extension Goal : Identifiable {

}
