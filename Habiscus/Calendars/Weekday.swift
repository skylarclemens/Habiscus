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
    
    public var id: Self { self }
}
