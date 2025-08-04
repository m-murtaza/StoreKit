//
//  CacheStoreFactory.swift
//  StoreKit
//
//  Created by Mashud Murtaza on 04/08/2025.
//

import Foundation

public final class StoreFactory {
    public static func cacheStore() -> StoreType {
        let managedObject = ManagedObject()
        return CacheStore(managedObject: managedObject)
    }
    
    public static func defaultStore() -> StoreType {
        return DefaultStore()
    }
}
