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
    
    func validDaysBetween(_ stopDate: Date, in weekdays: [Weekday], direction: Calendar.SearchDirection = .backward) -> Int? {
        var result: [Date] = []
        let weekdayNumbers = weekdays.compactMap {
            if let num = Weekday.allValues.firstIndex(of: $0) {
                return Int(num + 1)
            } else {
                return nil
            }
        }.sorted()
        let prevDay = Calendar.current.date(byAdding: .day, value: -1, to: self)!
        
        Calendar.current.enumerateDates(startingAfter: prevDay, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) { (date, _, stop) in
            if let date = date,
               date <= stopDate {
                let weekday = Calendar.current.component(.weekday, from: date)
                if weekdayNumbers.contains(weekday) {
                    result.append(date)
                }
            } else {
                stop = true
            }
        }
        
        return result.count
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    public var localDate: Date {
        let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: Date())
        return Calendar.autoupdatingCurrent.date(from: dateComponents)!
    }
    
    public var currentWeekdayString: String {
        self.formatted(Date.FormatStyle().weekday(.wide))
    }
    
    public var currentWeekday: Weekday {
        Weekday(rawValue: currentWeekdayString.localizedLowercase)!
    }
    
    func getWeekdayDate(weekdayNumber: Int, endDate: Date, direction: Calendar.SearchDirection = .forward) -> Date? {
        var result: Date?
        Calendar.current.enumerateDates(startingAfter: self, matching: DateComponents(weekday: weekdayNumber), matchingPolicy: .nextTime, direction: direction) { (date, _, stop) in
            if let date = date,
               (direction == .forward && date <= endDate) || (direction == .backward && date >= endDate) {
                    result = date
            } else {
                stop = true
            }
        }
        
        return result
    }
    
    func findWeekdayDate(in weekdays: [Weekday], direction: Calendar.SearchDirection = .forward) -> Date? {
        guard weekdays.contains(self.currentWeekday) else { return nil }
        
        let directionValue = direction == .forward ? 1 : -1
        guard let currentWeekdayNum = Weekday.allValues.firstIndex(of: self.currentWeekday),
              let findWeek = Calendar.current.date(byAdding: .weekOfYear, value: directionValue, to: self) else {
            return nil
        }
        
        let weekdayNumbers = weekdays.compactMap { Weekday.allValues.firstIndex(of: $0) }.sorted()
        if weekdayNumbers.count == 1 {
            return Calendar.current.date(byAdding: .weekOfYear, value: directionValue, to: self)
        }
        
        guard let currentIndex = weekdayNumbers.firstIndex(of: currentWeekdayNum) else {
            return nil
        }
        
        let findIndex = (currentIndex + directionValue) % weekdayNumbers.count
        let findWeekdayNum = weekdayNumbers[findIndex]
        
        return self.getWeekdayDate(weekdayNumber: findWeekdayNum + 1, endDate: findWeek, direction: direction)
    }
    
    func closestPreviousWeekday(in weekdays: [Weekday]) -> Date? {
        guard let currentWeekdayNum = Weekday.allValues.firstIndex(of: self.currentWeekday),
              let findWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: self) else {
            return nil
        }
        let weekdayNumbers = weekdays.compactMap { Weekday.allValues.firstIndex(of: $0) }.sorted()
        let closestWeekday = weekdayNumbers.reduce(weekdayNumbers[0]) {
            if $1 >= currentWeekdayNum {
                return $0
            } else {
                return abs($0 - currentWeekdayNum) < abs($1 - currentWeekdayNum) ? $0 : $1
            }
        }
        
        return self.getWeekdayDate(weekdayNumber: closestWeekday + 1, endDate: findWeek, direction: .backward)
    }
}
