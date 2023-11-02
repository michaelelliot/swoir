// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SimpleUsage",
    dependencies: [
        .package(path: "../../")
    ],
    targets: [
        .executableTarget(
            name: "SimpleUsage",
            dependencies: ["Swoir"],
            exclude: [
                "Resources/noir-project/src/main.nr",
                "Resources/noir-project/Nargo.toml"
            ],
            resources: [
                .process("Resources/noir-project/target/swoir_example.json")
            ]
        )
    ]
)
