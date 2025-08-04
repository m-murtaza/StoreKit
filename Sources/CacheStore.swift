//
//  CacheStore.swift
//  StoreKit
//
//  Created by Mashud Murtaza on 04/08/2025.
//

import Foundation
import CoreData

enum StoreError: Error {
    case storeNotAvailable
}

final class CacheStore: NSObject {
    // MARK: - Properties
    private let managedObject: ManagedObjectType
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var observingControllers: [ObservingController] = []
    
    // MARK: - Initialization
    init(
        managedObject: ManagedObjectType,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.managedObject = managedObject
        self.encoder = encoder
        self.decoder = decoder
        
        super.init()
        startObservingDataChanges()
    }
}

extension CacheStore: StoreType {
    func save<T>(data: T, for key: String) throws where T : Encodable {
        guard let context = managedObject.context else {
            throw StoreError.storeNotAvailable
        }
        
        let fetchRequest: NSFetchRequest<Cache> = Cache.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "key == %@", key)
        
        try performOnMainThread { [weak self, weak context] in
            guard let context, let encoder = self?.encoder else { return }
            let cache = (try? context.fetch(fetchRequest))?.first ?? Cache(context: context)
            cache.data = try encoder.encode(data)
            cache.updatedAt = Date()
            cache.key = key
            
            try context.save()
        }
    }
    
    func data<T>(for key: String) throws -> T? where T : Decodable {
        guard let context = managedObject.context else {
            throw StoreError.storeNotAvailable
        }
        
        let fetchRequest: NSFetchRequest<Cache> = Cache.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "key == %@", key)
        
        var cache: Cache?
        try performOnMainThread { [weak context] in
            cache = (try context?.fetch(fetchRequest))?.first
        }
        
        guard let data = cache?.data else { return nil }
        let cachedData = try decoder.decode(T.self, from: data)

        return cachedData
    }
    
    func lastUpdatedAt(for key: String) throws -> Date? {
        guard let context = managedObject.context else {
            throw StoreError.storeNotAvailable
        }
        
        let fetchRequest: NSFetchRequest<Cache> = Cache.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "key == %@", key)
        var updatedAt: Date?
        try performOnMainThread { [weak context] in
            updatedAt = (try context?.fetch(fetchRequest))?.first?.updatedAt
        }
        
        return updatedAt
    }
    
    func deleteData(for key: String) throws {
        guard let context = managedObject.context else {
            throw StoreError.storeNotAvailable
        }
        
        let fetchRequest: NSFetchRequest<Cache> = Cache.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "key == %@", key)
        try performOnMainThread { [weak self, weak context] in
            guard let caches = try context?.fetch(fetchRequest) else {
                return
            }
            
            for cache in caches {
                context?.delete(cache)
            }
            
            try context?.save()
            self?.observingControllers.filter({ $0.key == key }).forEach({ $0.observationHandler?() })
        }
    }
    
    func startObservingUpdates(for key: String, observationHandler: @escaping () -> Void) {
        observingControllers.append(ObservingController(key: key, observationHandler: observationHandler))
    }
    
    func clear() throws {
        guard let context = managedObject.context else {
            throw StoreError.storeNotAvailable
        }
        
        let fetchRequest: NSFetchRequest<Cache> = Cache.fetchRequest()
        guard let caches = try managedObject.context?.fetch(fetchRequest) else {
            return
        }
        
        for cache in caches {
            context.delete(cache)
        }
        
        try context.save()
    }
}

// MARK: - Observation
private extension CacheStore {
    func startObservingDataChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(contextUpdated(notification:)), name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    @objc func contextUpdated(notification: Notification) {
        guard !observingControllers.isEmpty, let userInfo = notification.userInfo else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let modifiedCaches: [Cache] = userInfo.modifiedData()
            for modifiedCache in modifiedCaches {
                guard let controller = self?.observingControllers.first(where: { $0.key == modifiedCache.key }) else { continue }
                DispatchQueue.main.async {
                    controller.observationHandler?()
                }
            }
        }
    }
}

// MARK: - Observing controller
private struct ObservingController {
    let key: String
    let observationHandler: (() -> Void)?
}

// MARK: - Data extraction
private extension Dictionary where Key == AnyHashable, Value: Any {
    func modifiedData<T: NSManagedObject>() -> [T] {
        var modified = [T]()
        
        for pair in self {
            guard let modifiedSet = pair.value as? Set<NSManagedObject> else { continue }
            modified += getModified(in: modifiedSet)
        }
        return modified
    }
    
    func getModified<T: NSManagedObject>(in set: Set<NSManagedObject>) -> [T] {
        var modified = [T]()
        for element in set {
            guard let typedElement = element as? T else { continue }
            modified.append(typedElement)
        }
        return modified
    }
}

// MARK: - Utils
private extension CacheStore {
    func performOnMainThread(_ block: @escaping () throws -> Void) throws {
        if Thread.isMainThread {
            try block()
        } else {
            debugPrint("Warning ⚠️: Cache Store accessed from background thread. Moving to main thread.")
            var blockError: Error?
            DispatchQueue.main.sync {
                do { try block() }
                catch { blockError = error }
            }
            guard let blockError else { return }
            throw blockError
        }
    }
}
