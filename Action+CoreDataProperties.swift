//
//  Action+CoreDataProperties.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/10/23.
//
//

import Foundation
import CoreData


extension Action {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Action> {
        return NSFetchRequest<Action>(entityName: "Action")
    }

    @NSManaged public var type: String?
    @NSManaged public var order: Int16
    @NSManaged public var date: Date?
    @NSManaged public var completed: Bool
    @NSManaged public var text: String?
    @NSManaged public var number: Double
    @NSManaged public var habit: Habit?
    @NSManaged public var progress: Progress?
    
    public var actionType: ActionType {
        ActionType(rawValue: type ?? "timer")!
    }
    
    public var timerHoursAndMintutes: (hours: Int , minutes: Int) {
        minutesToHoursAndMinutes(Int(number))
    }
    
    public func minutesToHoursAndMinutes(_ minutes: Int) -> (hours: Int , minutes: Int) {
        return (minutes / 60, (minutes % 60))
    }
}

extension Action : Identifiable {

}
