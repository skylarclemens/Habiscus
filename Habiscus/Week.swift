//
//  Week.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/27/23.
//

import Foundation
import SwiftUI

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        self.date(from: dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
    }
    
    func daysOfWeek(startingOn startDay: Date) -> [Date] {
        (0...6).map { self.date(byAdding: .day, value: $0, to: startDay)! }
    }
}

struct Week: Hashable {
    var initialDate: Date
    var currentWeek: [Date] {
        calculateWeek(for: initialDate)
    }
    
    enum RelatedWeeks {
        case previous, next
    }
    
    //Initialize week to today's date
    init() {
        self.initialDate = Date()
    }
    
    //Set the day to get the week
    init(initialDate: Date) {
        self.initialDate = initialDate
    }
    
    func getRelatedWeek(_ direction: RelatedWeeks) -> Week {
        let dayValue = direction == .next ? 7 : -7
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: dayValue, to: self.initialDate)!
        return Week(initialDate: oneWeekAgo)
    }
    
    func getRelatedWeeks() -> [Week] {
        return [self.getRelatedWeek(.previous), self, self.getRelatedWeek(.next)]
    }
    
    private func calculateWeek(for date: Date) -> [Date] {
        let startOfWeek = Calendar.current.startOfWeek(for: date)
        return Calendar.current.daysOfWeek(startingOn: startOfWeek)
    }
    
    private func calculateWeek(starting startDate: Date) -> [Date] {
        Calendar.current.daysOfWeek(startingOn: startDate)
    }
}
