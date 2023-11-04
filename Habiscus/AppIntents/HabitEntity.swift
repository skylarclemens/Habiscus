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
    
    @Property(title: "Color")
    var color: String
    
    @Property(title: "Last updated")
    var lastUpdated: Date
    
    @Property(title: "Archived")
    var isArchived: Bool
    
    init(id: UUID, name: String?, createdAt: Date?, startDate: Date?, endDate: Date?, color: String?, lastUpdated: Date?, isArchived: Bool) {
        let habitName = name ?? "Unknown name"
        
        self.id = id
        self.name = habitName
        self.createdAt = createdAt ?? Date()
        self.startDate = startDate ?? Date()
        self.endDate = endDate
        self.color = color ?? "pink"
        self.lastUpdated = lastUpdated ?? Date()
        self.isArchived = isArchived
    }
}

struct HabitQuery: EntityPropertyQuery {
    func entities(for identifiers: [UUID]) async throws -> [HabitEntity] {
        return try HabitsManager.shared.findHabits(for: identifiers).map {
            HabitEntity(
                id: $0.id!,
                name: $0.name,
                createdAt: $0.createdAt,
                startDate: $0.startDate,
                endDate: $0.endDate,
                color: $0.color,
                lastUpdated: $0.lastUpdated,
                isArchived: $0.isArchived
            )
        }
    }
    
    func suggestedEntities() async throws -> [HabitEntity] {
        let habits = HabitsManager.shared.getAllHabits().filter { !$0.isArchived }
        return habits.map {
            HabitEntity(
                id: $0.id!,
                name: $0.name,
                createdAt: $0.createdAt,
                startDate: $0.startDate,
                endDate: $0.endDate,
                color: $0.color,
                lastUpdated: $0.lastUpdated,
                isArchived: $0.isArchived
            )
        }
    }
    
    func entities(matching string: String) async throws -> [HabitEntity] {
        let filteredHabits = HabitsManager.shared.getAllHabits().filter { habit in
            habit.wrappedName.lowercased().localizedCaseInsensitiveContains(string.lowercased())
        }
        
        return filteredHabits.map {
            HabitEntity(
                id: $0.id!,
                name: $0.name,
                createdAt: $0.createdAt,
                startDate: $0.startDate,
                endDate: $0.endDate,
                color: $0.color,
                lastUpdated: $0.lastUpdated,
                isArchived: $0.isArchived)
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
        let predicate = NSCompoundPredicate(type: mode == .and ? .and : .or, subpredicates: comparators)
        let sortDescriptors = toSortDescriptor(sortedBy)
        let matchingHabits = try context.fetch(request)
        return matchingHabits.map {
            HabitEntity(
                id: $0.id!,
                name: $0.name,
                createdAt: $0.createdAt,
                startDate: $0.startDate,
                endDate: $0.endDate,
                color: $0.color,
                lastUpdated: $0.lastUpdated,
                isArchived: $0.isArchived)
        }
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
