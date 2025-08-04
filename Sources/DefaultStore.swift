//
//  DefaultStore.swift
//  StoreKit
//
//  Created by Mashud Murtaza on 04/08/2025.
//

import Foundation

final class DefaultStore {
    // MARK: - Properties
    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var observingControllers: [ObservingController] = []
    
    // MARK: - Initialization
    init(
        userDefaults: UserDefaults = .standard,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.userDefaults = userDefaults
        self.encoder = encoder
        self.decoder = decoder
    }
}

extension DefaultStore: StoreType {
    func save<T>(data: T, for key: String) throws where T : Encodable {
        let encodedData: Data = try encoder.encode(data)
        userDefaults.set(encodedData, forKey: key)
        notifyDataChanges(for: key)
    }
    
    func data<T>(for key: String) throws -> T? where T : Decodable {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try decoder.decode(T.self, from: data)
    }
    
    func lastUpdatedAt(for key: String) throws -> Date? {
        return nil
    }
    
    func deleteData(for key: String) throws {
        userDefaults.removeObject(forKey: key)
        notifyDataChanges(for: key)
    }
    
    func startObservingUpdates(for key: String, observationHandler: @escaping () -> Void) {
        observingControllers.append(ObservingController(key: key, observationHandler: observationHandler))
    }
    
    func clear() throws { }
}

// MARK: - Utils
private extension DefaultStore {
    func notifyDataChanges(for key: String) {
        observingControllers.filter({ $0.key == key }).forEach({ $0.observationHandler?() })
    }
}

// MARK: - Observing controller
private struct ObservingController {
    let key: String
    let observationHandler: (() -> Void)?
}
