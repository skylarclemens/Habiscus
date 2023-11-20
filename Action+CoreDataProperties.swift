//
//  Action+CoreDataProperties.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/12/23.
//
//

import Foundation
import CoreData


extension Action {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Action> {
        return NSFetchRequest<Action>(entityName: "Action")
    }

    @NSManaged public var completed: Bool
    @NSManaged public var date: Date?
    @NSManaged public var number: Double
    @NSManaged public var order: Int16
    @NSManaged public var text: String?
    @NSManaged public var type: String?
    @NSManaged public var elapsedTime: Double
    @NSManaged public var isTimerRunning: Bool
    @NSManaged public var habit: Habit?
    @NSManaged public var progress: Progress?
    
    public var actionType: ActionType {
        ActionType(rawValue: type ?? "timer")!
    }
    
    public var actionTypeString: String {
        ActionType(rawValue: wrappedType)?.label() ?? ""
    }
    
    public var wrappedType: String {
        type ?? ""
    }
    
    public var wrappedDate: Date {
        date ?? Date()
    }
    
    public var timerHoursAndMintutes: (hours: Int , minutes: Int) {
        intervalToHoursAndMinutes(Int(number))
    }
    
    public func intervalToHoursAndMinutes(_ interval: Int) -> (hours: Int , minutes: Int) {
        return ((interval / 3600), (interval / 60) % 60)
    }
    
    public func toggleTimer() {
        self.isTimerRunning.toggle()
    }
    
    public func resetTimer() {
        self.elapsedTime = 0
        self.isTimerRunning = false
    }
}

extension Action : Identifiable {

}
