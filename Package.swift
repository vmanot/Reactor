// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Reduce",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "Reduce", targets: ["Reduce"])
    ],
    dependencies: [
        .package(url: "git@github.com:vmanot/API.git", .branch("master")),
        .package(url: "git@github.com:vmanot/Merge.git", .branch("master")),
        .package(url: "git@github.com:vmanot/SwiftUIX.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "Reduce",
            dependencies: [
                "API",
                "Merge",
                "SwiftUIX"
            ],
            path: "Sources"
        ),
    ],
    swiftLanguageVersions: [
        .version("5.1")
    ]
)
