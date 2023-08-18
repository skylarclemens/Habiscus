//
//  Repeat.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/18/23.
//

import Foundation

struct Repeat {
    var repeats: Bool = true
    // When Habit repeats (daily, weekly, etc.)
    var repeatOption: RepeatOptions
    // How often the habit repeats every repeatOption
    // every 5 days, every 2 weeks, every 3 months, etc.
    var frequency: Int
    var weekdays: Set<Weekday>
    var days: [Int]
    
    /*var frequency: Int {
        switch repeatOption {
        case .daily:
            return 1
        case .weekdays:
            return 5
        case .weekends:
            return 2
        case .weekly:
            return weekdays.count
        }
    }*/
}
