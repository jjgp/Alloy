// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Alloy",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Alloy",
            targets: ["Alloy"]),
    ],
    targets: [
        .target(
            name: "Alloy",
            dependencies: []),
        .testTarget(
            name: "AlloyTests",
            dependencies: ["Alloy"]),
    ]
)
