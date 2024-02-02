//
//  HabitModel.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/6/23.
//

import Foundation
import SwiftUI

public struct HabitModel {
    let id: UUID
    var name: String
    var emojiIcon: String
    var color: String
    var count: Int
    var goal: Int
    var unit: String
    
    var habitColor: Color {
        Color(color)
    }
    
    static var example = HabitModel(id: UUID(), name: "Habit", emojiIcon: "🤩", color: "habiscusBlue", count: 1, goal: 2, unit: "completed")
    
    init(id: UUID, name: String, emojiIcon: String, color: String, count: Int, goal: Int, unit: String) {
        self.id = UUID()
        self.name = name
        self.emojiIcon = emojiIcon
        self.color = color
        self.count = count
        self.goal = goal
        self.unit = unit
    }
    
    init(habit: Habit) {
        self.id = habit.id!
        self.name = habit.wrappedName
        self.emojiIcon = habit.emojiIcon
        self.color = habit.color ?? "habiscusPink"
        self.count = habit.getCountByDate(from: Date())
        self.goal = habit.goalNumber
        self.unit = habit.wrappedUnit
    }
    
    init(habit: Habit, date: Date) {
        self.id = habit.id!
        self.name = habit.wrappedName
        self.emojiIcon = habit.emojiIcon
        self.color = habit.color ?? "habiscusPink"
        self.count = habit.getCountByDate(from: date)
        self.goal = habit.goalNumber
        self.unit = habit.wrappedUnit
    }
}
