//
//  PersistanceService.swift
//  AlarmTest
//
//  Created by Rdm on 16/05/2022.
//

import Foundation
import CoreData


class PersistanceService {
    
    init() {}
    
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Alarm")
        container.loadPersistentStores(completionHandler: { success, err in
            if let err = err as? NSError {
                fatalError("Fatal Error: \(err), Error description: \(err.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: CoreData managing support
    
    static func saveContext() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                print("Data successfully saved")
            } catch {
                let nserror = error as NSError
                print("Unresolved error: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    static func deleteObject(object: NSManagedObject) {
        let context = persistentContainer.viewContext
        context.delete(object)
        print("Object deleted successfully")
    }
}
