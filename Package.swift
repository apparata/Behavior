// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "Behavior",
    platforms: [
        .iOS(.v15), .macOS(.v12), .tvOS(.v15), .visionOS(.v1)
    ],
    products: [
        .library(name: "Behavior", targets: ["Behavior"])
    ],
    targets: [
        .target(
            name: "Behavior",
            dependencies: [],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release)),
                .define("SWIFT_PACKAGE")
            ]),
        .testTarget(name: "BehaviorTests", dependencies: ["Behavior"]),
    ]
)
