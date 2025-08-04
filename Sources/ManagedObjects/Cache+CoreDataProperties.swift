//
//  Cache+CoreDataProperties.swift
//  StoreKit
//
//  Created by Mashud Murtaza on 04/08/2025.
//
//

import Foundation
import CoreData


extension Cache {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cache> {
        return NSFetchRequest<Cache>(entityName: "Cache")
    }

    @NSManaged public var data: Data?
    @NSManaged public var key: String?
    @NSManaged public var updatedAt: Date?

}
