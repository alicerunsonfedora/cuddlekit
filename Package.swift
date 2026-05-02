// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "CuddleKit",
    platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v16), .watchOS(.v9)],
    products: [
        .library(name: "CuddleKit", targets: ["CuddleKit"]),
        .library(name: "CKDL", targets: ["CKDL"])
    ],
    traits: [
        .default(enabledTraits: []),
        .trait(name: "Embedded"),
        .trait(name: "Playdate", enabledTraits: ["Embedded"])
    ],
    targets: [
        .target(
            name: "CKDL",
            exclude: ["src/utils", "doc", "bindings", "tests"],
            cSettings: [.unsafeFlags(["-v"])],
            swiftSettings: [
                .enableExperimentalFeature("Embedded", .when(traits: ["Embedded"])),
            ]
        ),
        .target(
            name: "CuddleKit",
            dependencies: ["CKDL"],
            swiftSettings: [
                .enableExperimentalFeature("Embedded", .when(traits: ["Embedded"])),
            ]
        ),
        .testTarget(
            name: "CuddleKitTests",
            dependencies: ["CuddleKit"]
        ),
    ]
)
