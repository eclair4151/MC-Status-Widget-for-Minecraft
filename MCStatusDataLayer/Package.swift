// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package

import PackageDescription

let package = Package(
    name: "MCStatusDataLayer",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v17),
        .watchOS(.v10),
        .macCatalyst(.v17),
        .visionOS(.v1)
    ], products: [
        // Products define the executables and libraries a package produces, making them visible to other packages
        .library(
            name: "MCStatusDataLayer",
            targets: ["MCStatusDataLayer"]
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite
        // Targets can depend on other targets in this package and products from dependencies
        .target(
            name: "MCStatusDataLayer"
        ),
        .testTarget(
            name: "MCStatusDataLayerTests",
            dependencies: ["MCStatusDataLayer"]
        )
    ]
)
