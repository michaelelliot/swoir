// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Swoir",
    products: [
        .library(
            name: "Swoir",
            targets: ["Swoir"]),
    ],
    targets: [
        .target(
            name: "Swoir"
        ),
        .testTarget(
            name: "SwoirTests",
            dependencies: ["Swoir"],
            resources: [
                .process("Fixtures")
            ]
        ),
    ]
)
