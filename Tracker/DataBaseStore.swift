//
//  DataBaseStore.swift
//  Tracker
//
//  Created by Maryia Dziarkach on 24.05.26.
//

import CoreData

final class DataBaseStore {
    static let shared = DataBaseStore()

    let persistentContainer: NSPersistentContainer

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private init() {
        persistentContainer = NSPersistentContainer(name: "Tracker")
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Ошибка CoreData: \(error)")
            }
        }
    }

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
