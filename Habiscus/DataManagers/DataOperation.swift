//
//  DataOperation.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/20/23.
//

import Foundation
import CoreData

struct DataOperation<Object: NSManagedObject>: Identifiable {
    let id = UUID()
    let childContext: NSManagedObjectContext
    let childObject: Object
    
    // Add new object
    init(withContext parentContext: NSManagedObjectContext) {
        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = parentContext
        
        self.childContext = childContext
        self.childObject = Object(context: childContext)
    }
    
    // Edit existing object
    init(withExistsingData object: Object, in parentContext: NSManagedObjectContext) {
        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = parentContext
        
        self.childContext = childContext
        self.childObject = childContext.object(with: object.objectID) as! Object
    }
}
