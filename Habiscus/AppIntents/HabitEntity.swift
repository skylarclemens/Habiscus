//
//  HabiscusHabits.swift
//  HabiscusAppIntents
//
//  Created by Skylar Clemens on 8/23/23.
//

import AppIntents
import CoreData
import SwiftUI

struct HabitEntity: AppEntity, Identifiable {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(stringLiteral: "Habit")
    var displayRepresentation: DisplayRepresentation { DisplayRepresentation(title: "\(name)") }
    typealias DefaultQueryType = HabitQuery
    static var defaultQuery: HabitQuery = HabitQuery()
    
    let id: UUID
    
    @Property(title: "Name")
    var name: String
    
    @Property(title: "Created on")
    var createdAt: Date
    
    @Property(title: "Started on")
    var startDate: Date
    
    @Property(title: "Ends on")
    var endDate: Date?
    
    @Property(title: "Type")
    var type: String
    
    @Property(title: "Progress method")
    var progressMethod: String
    
    @Property(title: "Icon")
    var icon: String
    
    @Property(title: "Color")
    var color: String
    
    @Property(title: "Today's count")
    var count: Int
    
    @Property(title: "Goal")
    var goal: Int
    
    @Property(title: "Unit")
    var unit: String
    
    @Property(title: "Last updated")
    var lastUpdated: Date
    
    @Property(title: "Archived")
    var isArchived: Bool
    
    var url: URL? {
        URL(string: "habiscus://open-habit?id=\(id)")
    }
    
    init(id: UUID, name: String?, createdAt: Date?, startDate: Date?, endDate: Date?, type: String?, progressMethod: String?, icon: String, color: String?, count: Int, goal: Int, unit: String, lastUpdated: Date?, isArchived: Bool) {
        let habitName = name ?? "Unknown name"
        
        self.id = id
        self.name = habitName
        self.createdAt = createdAt ?? Date()
        self.startDate = startDate ?? Date()
        self.endDate = endDate
        self.type = type ?? "build"
        self.progressMethod = progressMethod ?? "counts"
        self.icon = icon
        self.color = color ?? "habiscusPink"
        self.count = count
        self.goal = goal
        self.unit = unit
        self.lastUpdated = lastUpdated ?? Date()
        self.isArchived = isArchived
    }
    
    init(habit: Habit) {
        self.id = habit.id ?? UUID()
        self.name = habit.wrappedName
        self.createdAt = habit.createdDate
        self.startDate = habit.startDate ?? Date()
        self.endDate = habit.endDate
        self.type = habit.type ?? "build"
        self.progressMethod = habit.progressMethod ?? "counts"
        self.icon = habit.emojiIcon
        self.color = habit.color ?? "habiscusPink"
        self.count = habit.getCountByDate(from: Date())
        self.goal = habit.goalNumber
        self.unit = habit.wrappedUnit
        self.lastUpdated = habit.lastUpdated ?? Date()
        self.isArchived = habit.isArchived
    }
    
    static let example: HabitEntity = HabitEntity(id: UUID(), name: "Habit", createdAt: Date(), startDate: Date(), endDate: nil, type: "build", progressMethod: "counts", icon: "👍", color: "habiscusBlue", count: 1, goal: 2, unit: "completed", lastUpdated: Date(), isArchived: false)
    static let example2: HabitEntity = HabitEntity(id: UUID(), name: "Habit2", createdAt: Date(), startDate: Date(), endDate: nil, type: "build", progressMethod: "action", icon: "🎉", color: "habiscusPink", count: 4, goal: 5, unit: "add", lastUpdated: Date(), isArchived: false)
    static let example3: HabitEntity = HabitEntity(id: UUID(), name: "Habit3", createdAt: Date(), startDate: Date(), endDate: nil, type: "quit", progressMethod: "counts", icon: "🚫", color: "habiscusGreen", count: 2, goal: 3, unit: "add", lastUpdated: Date(), isArchived: false)
}

struct HabitQuery: EntityPropertyQuery {
    func entities(for identifiers: [UUID]) async throws -> [HabitEntity] {
        guard let habits = try HabitsManager.shared.findHabits(for: identifiers) else {
            return []
        }
        return habits.map { HabitEntity(habit: $0) }
    }
    
    func entities(matching string: String) async throws -> [HabitEntity] {
        guard let habits = try? HabitsManager.shared.getAllHabits() else {
            return []
        }
            
        let filteredHabits = habits.filter { habit in
            habit.wrappedName.lowercased().localizedCaseInsensitiveContains(string.lowercased())
        }
        
        return filteredHabits.map { HabitEntity(habit: $0) }
    }
    
    func suggestedEntities() async throws -> [HabitEntity] {
        guard let habits = try HabitsManager.shared.getAllActiveHabits() else {
            return []
        }
        return habits.map { HabitEntity(habit: $0) }
    }
    
    func defaultResult() async -> HabitEntity? {
        do {
            return try await self.suggestedEntities().first
        } catch {
            return nil
        }
    }
    
    static var sortingOptions = SortingOptions {
        SortableBy(\HabitEntity.$name)
        SortableBy(\HabitEntity.$startDate)
        SortableBy(\HabitEntity.$createdAt)
        SortableBy(\HabitEntity.$lastUpdated)
        SortableBy(\HabitEntity.$isArchived)
    }
    
    static var properties = EntityQueryProperties<HabitEntity, NSPredicate> {
        Property(\HabitEntity.$name) {
            EqualToComparator { NSPredicate(format: "name = %@", $0) }
            ContainsComparator { NSPredicate(format: "name CONTAINS %@", $0) }
        }
        Property(\HabitEntity.$startDate) {
            LessThanComparator { NSPredicate(format: "startDate < %@", $0 as NSDate ) }
            GreaterThanComparator { NSPredicate(format: "startDate > %@", $0 as NSDate) }
        }
        Property(\HabitEntity.$createdAt) {
            LessThanComparator { NSPredicate(format: "createdAt < %@", $0 as NSDate ) }
            GreaterThanComparator { NSPredicate(format: "createdAt > %@", $0 as NSDate) }
        }
        Property(\HabitEntity.$lastUpdated) {
            LessThanComparator { NSPredicate(format: "lastUpdated < %@", $0 as NSDate ) }
            GreaterThanComparator { NSPredicate(format: "lastUpdated > %@", $0 as NSDate) }
        }
        Property(\HabitEntity.$isArchived) {
            EqualToComparator { NSPredicate(format: "isArchived = %@", NSNumber(value: $0)) }
        }
    }
    
    func entities(matching comparators: [NSPredicate],
                  mode: ComparatorMode,
                  sortedBy: [Sort<HabitEntity>],
                  limit: Int?
    ) async throws -> [HabitEntity] {
        let context = DataController.shared.container.viewContext
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        //let predicate = NSCompoundPredicate(type: mode == .and ? .and : .or, subpredicates: comparators)
        //let sortDescriptors = toSortDescriptor(sortedBy)
        let matchingHabits = try context.fetch(request)
        return matchingHabits.map { HabitEntity(habit: $0) }
    }
    
    private func toSortDescriptor(_ sortedBy: [Sort<HabitEntity>]) -> [NSSortDescriptor] {
        var sortDescriptors = [NSSortDescriptor]()
        if let sort = sortedBy.first {
            switch sort.by {
            case \.$name:
                sortDescriptors.append(NSSortDescriptor(keyPath: \HabitEntity.name, ascending: sort.order == .ascending))
            default:
                break
            }
        }
        return sortDescriptors
    }
}
