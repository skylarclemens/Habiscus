//
//  DataController.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/23/23.
//

import CoreData
import Foundation
import CloudKit

class DataController: ObservableObject {
    static let shared = DataController()
        
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Habiscus")
        
        let url = URL.storeURL(for: "group.com.SkylarClemens.Habiscus", databaseName: "Habiscus")
        let storeDescription = NSPersistentStoreDescription(url: url)
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.SkylarClemens.Habiscus")
        container.persistentStoreDescriptions = [storeDescription]
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        guard container.persistentStoreDescriptions.first?.url?.path != nil else {
            fatalError("error getting path")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        #if DEBUG
        do {
            // Use the container to initialize the development schema.
            let options = NSPersistentCloudKitContainerSchemaInitializationOptions()
            try self.container.initializeCloudKitSchema(options: options)
        } catch {
            print("Failed to initialize schema: \(error)")
            // Handle any errors.
        }
        #endif
    }
    
    private func iCloudStatus() {
        CKContainer.default().accountStatus { returnedStatus, returnedError in
            DispatchQueue.main.async {
                switch returnedStatus {
                case .couldNotDetermine:
                    print("Could not determine")
                    return
                case .available:
                    print("Signed in")
                    return
                case .restricted:
                    print("Restricted")
                    return
                case .noAccount:
                    print("No account")
                    return
                case .temporarilyUnavailable:
                    print("Temporarily unavailable")
                    return
                @unknown default:
                    print("Unknown")
                    return
                }
            }
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
