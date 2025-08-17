// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReadMoreLabel",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "ReadMoreLabel",
            targets: ["ReadMoreLabel"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ReadMoreLabel",
            dependencies: []
        ),
        .testTarget(
            name: "ReadMoreLabelTests",
            dependencies: ["ReadMoreLabel"]
        ),
    ]
)
