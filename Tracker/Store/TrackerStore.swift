//
//  TrackerStore.swift
//  Tracker
//
//  Created by Maryia Dziarkach on 17.05.26.
//

import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdate(_ store: TrackerStore)
}

final class TrackerStore: NSObject {
    
    // MARK: - Properties
    
    private let context: NSManagedObjectContext
    weak var delegate: TrackerStoreDelegate?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let request = TrackerCoreData.fetchRequest()
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
        super.init()
        _ = fetchedResultsController
    }
    
    convenience override init() {
        self.init(context: DataBaseStore.shared.context)
    }
    
    // MARK: - Public Methods
    
    func createTracker(_ tracker: Tracker, category: TrackerCategoryCoreData) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color
        trackerCoreData.schedule = tracker.schedule.map { $0.rawValue } as NSObject
        trackerCoreData.category = category
        
        try context.save()
    }
    
    func fetchTrackers() throws -> [Tracker] {
        guard let trackersCoreData = fetchedResultsController.fetchedObjects else {
            return []
        }
        
        return trackersCoreData.compactMap { trackerCoreData in
            guard
                let id = trackerCoreData.id,
                let title = trackerCoreData.title,
                let emoji = trackerCoreData.emoji,
                let color = trackerCoreData.color as? UIColor,
                let scheduleRawValues = trackerCoreData.schedule as? [String]
            else { return nil }
            
            return Tracker(
                id: id,
                title: title,
                color: color,
                emoji: emoji,
                schedule: scheduleRawValues.compactMap { Weekday(rawValue: $0) }
            )
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        delegate?.trackerStoreDidUpdate(self)
    }
}
