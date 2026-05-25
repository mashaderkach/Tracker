//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Maryia Dziarkach on 17.05.26.
//

import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidUpdate(_ store: TrackerRecordStore)
}

final class TrackerRecordStore: NSObject {
    
    // MARK: - Properties
    
    private let context: NSManagedObjectContext
    weak var delegate: TrackerRecordStoreDelegate?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let request = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
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
    
    func addRecord(_ record: TrackerRecord) throws {
        guard let trackerCoreData = try fetchTrackerCoreData(id: record.trackerId) else { return }
        
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.date = record.date
        recordCoreData.tracker = trackerCoreData
        
        try context.save()
    }
    
    func deleteRecord(_ record: TrackerRecord) throws {
        guard let recordCoreData = try fetchRecordCoreData(record) else { return }
        
        context.delete(recordCoreData)
        try context.save()
    }
    
    // MARK: - Private Methods
    
    private func fetchTrackerCoreData(id: UUID) throws -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        return try context.fetch(request).first
    }
    
    private func fetchRecordCoreData(_ record: TrackerRecord) throws -> TrackerRecordCoreData? {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "tracker.id == %@ AND date == %@",
            record.trackerId as CVarArg,
            record.date as NSDate
        )
        request.fetchLimit = 1
        
        return try context.fetch(request).first
    }
    
    func fetchRecords() throws -> [TrackerRecord] {
        guard let recordsCoreData = fetchedResultsController.fetchedObjects else {
            return []
        }
        
        return recordsCoreData.compactMap { recordCoreData in
            guard
                let date = recordCoreData.date,
                let trackerId = recordCoreData.tracker?.id
            else { return nil }
            
            return TrackerRecord(trackerId: trackerId, date: date)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        delegate?.trackerRecordStoreDidUpdate(self)
    }
}
