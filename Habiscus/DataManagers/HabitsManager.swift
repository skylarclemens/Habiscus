//
//  HabitsManager.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/23/23.
//

import Foundation

import Foundation
import CoreData
import UserNotifications

class HabitsManager: ObservableObject {
    static let shared = HabitsManager()
    
    let context = DataController.shared.container.viewContext
    
    func getAllHabits() -> [Habit] {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        do {
            return try context.fetch(request)
        } catch let error {
            print("Fetch all habits failed: \(error.localizedDescription)")
        }
        return []
    }
    
    func getAllActiveHabits() throws -> [Habit] {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == NO")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        do {
            return try context.fetch(request)
        } catch let error {
            print("Fetch all active habits failed: \(error.localizedDescription)")
        }
        return []
    }
    
    func findHabit(id: UUID) throws -> Habit {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id as CVarArg)
        request.fetchLimit = 1
        do {
            guard let habit = try context.fetch(request).first else {
                throw Errors.notFound
            }
            return habit
        } catch {
            throw Errors.notFound
        }
    }
    
    func findHabits(for ids: [UUID]) throws -> [Habit] {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", ids)
        do {
            let habits = try context.fetch(request)
            guard !habits.isEmpty else {
                throw Errors.notFound
            }
            return habits
        } catch {
            throw Errors.notFound
        }
    }
    
    func findHabitByName(name: String) throws -> Habit {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", name)
        request.fetchLimit = 1
        do {
            guard let habit = try context.fetch(request).first else {
                throw Errors.notFound
            }
            return habit
        } catch {
            throw Errors.notFound
        }
    }
    
    func findHabitsByName(name: String) throws -> [Habit] {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", name)
        do {
            let habits = try context.fetch(request)
            guard !habits.isEmpty else {
                throw Errors.notFound
            }
            return habits
        } catch {
            throw Errors.notFound
        }
    }
}
