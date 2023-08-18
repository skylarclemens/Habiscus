//
//  Weekday.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/16/23.
//

import Foundation

public enum Weekday: String, CaseIterable, Identifiable {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday
    
    static let allValues = [sunday, monday, tuesday, wednesday, thursday, friday, saturday]
    static let weekdayNums = [
        sunday: 1,
        monday: 2,
        tuesday: 3,
        wednesday: 4,
        thursday: 5,
        friday: 6,
        saturday: 7
    ]
    
    public var id: Self { self }
}
