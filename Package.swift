// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Observable",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Observable",
            targets: ["Observable"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/aetherealtech/SwiftEventStreams.git", .branch("master")),
        .package(url: "https://github.com/aetherealtech/SwiftObserver.git", .branch("master")),
        .package(url: "https://github.com/aetherealtech/SwiftScheduling.git", .branch("master")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Observable",
            dependencies: [
                .product(name: "EventStreams", package: "SwiftEventStreams"),
                .product(name: "Observer", package: "SwiftObserver"),
                .product(name: "Scheduling", package: "SwiftScheduling"),
            ]),
        .testTarget(
            name: "ObservableTests",
            dependencies: ["Observable"]),
    ]
)
