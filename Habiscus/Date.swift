//
//  Date.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/1/23.
//

import Foundation

extension Date {
    // Number of days between two dates
    // Makes sure the dates both start at beginning of day so time does not interfere
    func daysBetween(_ date: Date) -> Int? {
        let startOfDaySelf = Calendar.current.startOfDay(for: self)
        let startOfDayDate = Calendar.current.startOfDay(for: date)
        let components = Calendar.current.dateComponents([.day], from: startOfDayDate, to: startOfDaySelf)
        return components.day
    }
    
    // Checks if days between dates is greater than 0 (current day)
    func isAfter(_ date: Date) -> Bool {
        daysBetween(date) ?? 0 > 0
    }
    
    // Checks if date is between one day before or after given date
    func isMoreThanOneDayFrom(_ date: Date) -> Bool {
        abs(daysBetween(date) ?? 0) > 1
    }
}
