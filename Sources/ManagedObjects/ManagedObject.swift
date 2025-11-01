//
//  ManagedObject.swift
//  PersistenceKit
//
//  Created by Mashud Murtaza on 04/08/2025.
//

import Foundation
import CoreData

protocol ManagedObjectType {
    var context: NSManagedObjectContext? { get }
}

final class ManagedObject: ManagedObjectType {
    // MARK: - Properties
    private(set) var context: NSManagedObjectContext?
    private var container: NSPersistentContainer?
    private var syncCompletionHandler: ((Bool) -> Void)?
    private var observer: Any?
    private var syncCompleted = false
    
    // MARK: - Constants
    private enum Constant {
        static let dataModelName = "CacheStore"
        static let dataModelExtension = "momd"
    }
    
    // MARK: - Initialization
    init() {
        guard let modelUrl = Bundle.module.url(
            forResource: Constant.dataModelName,
            withExtension: Constant.dataModelExtension
        ),
              let managedObjectModel = NSManagedObjectModel(contentsOf: modelUrl)
        else { return }
        
        container = NSPersistentContainer(
            name: Constant.dataModelName,
            managedObjectModel: managedObjectModel
        )
        
        container?.loadPersistentStores { [weak self] _, _ in
            self?.context = self?.container?.viewContext
        }
    }
}
