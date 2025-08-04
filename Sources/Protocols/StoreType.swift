//
//  StoreType.swift
//  StoreKit
//
//  Created by Mashud Murtaza on 04/08/2025.
//

import Foundation

public protocol StoreType {
    func save<T>(data: T, for key: String) throws where T : Encodable
    func data<T>(for key: String) throws -> T? where T : Decodable
    func lastUpdatedAt(for key: String) throws -> Date?
    func deleteData(for key: String) throws
    func startObservingUpdates<T>(for key: String, observationHandler: @escaping (T) -> Void) throws where T: Decodable
    func clear() throws
}

// MARK: - Optional implementation
public extension StoreType {
    func startObservingUpdates<T>(for key: String, observationHandler: @escaping (T) -> Void) throws where T: Decodable { }
}

