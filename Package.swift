// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RockArch",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "RockArch",
            targets: ["RockArch"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RockArch",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "RockArchTests",
            dependencies: ["RockArch"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
