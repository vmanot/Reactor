// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "Reactor",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "Reactor", targets: ["Reactor"])
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftUIX/Coordinator.git", branch: "master"),
        .package(url: "https://github.com/vmanot/Merge.git", branch: "master"),
        .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "Reactor",
            dependencies: [
                "Coordinator",
                "Merge",
                "SwiftUIX"
            ],
            path: "Sources",
            swiftSettings: []
        ),
    ]
)
