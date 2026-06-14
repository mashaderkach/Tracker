//
//  DataBaseStore.swift
//  Tracker
//
//  Created by Maryia Dziarkach on 24.05.26.
//

import CoreData

final class DataBaseStore {
    
    // MARK: - Shared
    
    static let shared = DataBaseStore()

    // MARK: - Properties
    
    let persistentContainer: NSPersistentContainer

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Initialization
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Tracker")
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Ошибка CoreData: \(error)")
            }
        }
    }

    // MARK: - Public Methods
    
    func saveContext() {
        let context = persistentContainer.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                assertionFailure("Ошибка сохранения CoreData: \(error)")
            }
        }
    }
}
