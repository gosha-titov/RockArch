// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let libraryName = "RockArch"
let packageName = libraryName
let targetName  = libraryName
let testTargetName = targetName + "Tests"

let package = Package(
    name: packageName,
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: libraryName,
            targets: [targetName]),
    ],
    targets: [
        .target(
            name: targetName,
            dependencies: []
        ),
        .testTarget(
            name: testTargetName,
            dependencies: [.init(stringLiteral: targetName)]
        ),
    ],
    swiftLanguageVersions: [.v5]
)

