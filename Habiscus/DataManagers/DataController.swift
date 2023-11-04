//
//  DataController.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/23/23.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    static let shared = DataController()
        
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Habiscus")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load \(error.localizedDescription)")
            }
            
            self.container.viewContext.automaticallyMergesChangesFromParent = true
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
    }
    
    func getContext() -> NSManagedObjectContext {
        return self.container.viewContext
    }
    
    func saveContext() {
        let context = getContext()
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print("Could not save context: \(error)")
            }
        }
    }
    
    func batchDelete(of entityName: String) throws {
        let context = self.container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
            let deleteResult: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
            
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deleteResult, into: [context])
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

public extension URL {
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }
        
        return container.appendingPathComponent("\(databaseName).sqlite")
    }
}
