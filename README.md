# StoreKit
A lightweight Swift package offering two persistent storage solutions: DefaultStore backed by UserDefaults, and CacheStore powered by CoreData. Designed to plug into any Swift codebase, it provides a unified StoreType interface for storing, retrieving, observing, and deleting data with ease.

## ✨ Features
* 🧠 DefaultStore: Uses UserDefaults for simple, lightweight key-value storage.
* 🗂 CacheStore: Uses CoreData to persist data as binary blobs with metadata.
* 🔁 Observation Support: Listen for changes per key.
* ✅ Generic Support for any Codable type.
* 📦 Built for modular Swift codebases and supports reuse across targets/projects.

## 💾 Storage Types
### 🧠 DefaultStore (`UserDefaults`)
* Stores data using standard UserDefaults.
* Automatically encodes/decodes objects using Codable.
* Good for lightweight or session data.
* No timestamp tracking (i.e., lastUpdatedAt returns nil).
### 🗂 CacheStore (`CoreData`)
* Uses a single CoreData entity Cache with:
  * key: String
  * data: Binary Data
  * updatedAt: Date
* Stores data as Data (binary) encoded from Codable objects.
* Timestamps changes via updatedAt.
* Utilizes NSManagedObjectContext and NSPersistentContainer via the injected ManagedObjectType abstraction.

## 🛠 How It Works
Both stores conform to a shared protocol:
```
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
```

## 🧪 Example Usage
```
lazy public var cacheStore: any StoreType = StoreFactory.cacheStore()
lazy public var defaultStore: any StoreType = StoreFactory.defaultStore()

/// Save the data
try? cacheStore.save(data: <data>, for: <key>)

/// Get the data
let _ = try? cacheStore.data(for: <key>)

/// Start observing 
cacheStore.startObservingUpdates(for: <key>) {
  /// your code here
}

/// clear data
try? cacheStore.deleteData(for: <key>)
```

## 🚀 Integration
### Swift Package Manager
Add this repo to your Swift Package Manager dependencies:
```
.package(url: "https://github.com/m-murtaza/storekit.git", from: "1.0.0")
```

## 🧑‍💻 Author
Mashood Murtaza
Maintained and developed with ❤️ for scalable Swift architecture.

## 📄 License
MIT License – feel free to use, modify, and contribute!
