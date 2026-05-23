//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Maryia Dziarkach on 17.05.26.
//

import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidUpdate(_ store: TrackerCategoryStore)
}

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Properties
    
    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.trackerStore = TrackerStore(context: context)
        super.init()
        _ = fetchedResultsController
    }
    
    convenience override init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.init(context: appDelegate.persistentContainer.viewContext)
    }
    
    // MARK: - Public Methods
    
    func createCategoryIfNeeded(title: String) throws -> TrackerCategoryCoreData {
        if let existingCategory = try fetchCategoryCoreData(title: title) {
            return existingCategory
        }
        
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = title
        
        try context.save()
        return categoryCoreData
    }
    
    func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) throws {
        let categoryCoreData = try createCategoryIfNeeded(title: title)
        try trackerStore.createTracker(tracker, category: categoryCoreData)
    }
    
    func fetchCategories() throws -> [TrackerCategory] {
        guard let categoriesCoreData = fetchedResultsController.fetchedObjects else {
            return []
        }
        
        return categoriesCoreData.compactMap { categoryCoreData in
            guard let title = categoryCoreData.title else { return nil }
            
            let trackersCoreData = categoryCoreData.trackers?.allObjects as? [TrackerCoreData] ?? []
            
            let trackers: [Tracker] = trackersCoreData.compactMap { trackerCoreData in
                guard
                    let id = trackerCoreData.id,
                    let trackerTitle = trackerCoreData.title,
                    let emoji = trackerCoreData.emoji,
                    let color = trackerCoreData.color as? UIColor,
                    let scheduleRawValues = trackerCoreData.schedule as? [String]
                else {
                    return nil
                }
                
                let schedule = scheduleRawValues.compactMap { Weekday(rawValue: $0) }
                
                return Tracker(
                    id: id,
                    title: trackerTitle,
                    color: color,
                    emoji: emoji,
                    schedule: schedule
                )
            }
            
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchCategoryCoreData(title: String) throws -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1
        
        return try context.fetch(request).first
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        delegate?.trackerCategoryStoreDidUpdate(self)
    }
}
