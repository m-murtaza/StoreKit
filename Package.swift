// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "StoreKit",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "StoreKit",
            targets: ["StoreKit"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "StoreKit",
            path: "Sources"
        ),
        .testTarget(
            name: "StoreKitTests",
            dependencies: ["StoreKit"],
            path: "Tests"
        ),
    ]
)
