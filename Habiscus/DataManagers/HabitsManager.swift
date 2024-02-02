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
    
    func getAllHabits() throws -> [Habit]? {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        var habits: [Habit]?
        context.performAndWait {
            do {
                habits = try context.fetch(request)
            } catch let error {
                print("Fetch all habits failed: \(error.localizedDescription)")
            }
        }
        
        return habits
    }
    
    func getAllActiveHabits(refresh: Bool = false) throws -> [Habit]? {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == NO")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        var habits: [Habit]?
        context.performAndWait {
            if refresh {
                try? self.context.setQueryGenerationFrom(.current)
                self.context.refreshAllObjects()
            }
            
            do {
                habits = try context.fetch(request)
            } catch let error {
                print("Fetch all active habits failed: \(error.localizedDescription)")
            }
        }
        
        return habits
    }
    
    func findHabit(id: UUID, refresh: Bool = false) throws -> Habit? {
        var habit: Habit?
        
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id as CVarArg)
        request.fetchLimit = 1
        
        try context.performAndWait {
            if refresh {
                try? self.context.setQueryGenerationFrom(.current)
                self.context.refreshAllObjects()
            }
            
            do {
                habit = try context.fetch(request).first
            } catch {
                throw Errors.notFound
            }
        }
        
        return habit
    }
    
    func findHabits(for ids: [UUID], refresh: Bool = false) throws -> [Habit]? {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", ids)
        
        var habits: [Habit]?
        
        try context.performAndWait {
            if refresh {
                try? self.context.setQueryGenerationFrom(.current)
                self.context.refreshAllObjects()
            }
            
            do {
                habits = try context.fetch(request)
            } catch {
                throw Errors.notFound
            }
        }
        
        return habits
    }
    
    func findHabitByName(name: String) throws -> Habit? {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", name)
        request.fetchLimit = 1
        
        var habit: Habit?
        
        try context.performAndWait {
            do {
                habit = try context.fetch(request).first
            } catch {
                throw Errors.notFound
            }
        }
        
        return habit
    }
    
    func findHabitsByName(name: String) throws -> [Habit]? {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", name)
        
        var habits: [Habit]?
        
        try context.performAndWait {
            do {
                habits = try context.fetch(request)
            } catch {
                throw Errors.notFound
            }
        }
        
        return habits
    }
}
