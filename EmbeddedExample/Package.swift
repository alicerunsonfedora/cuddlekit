// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

/// Hack to force Xcode builds to not produce a dylib, since linking fails
/// without a toolset.json specified. Ideally this can be removed if/when
/// Xcode gains toolset.json support.
let xcode = (Context.environment["XPC_SERVICE_NAME"]?.count ?? 0) > 2

let playdateSDKPath: String =
    if let path = Context.environment["PLAYDATE_SDK_PATH"] {
        path
    } else {
        "\(Context.environment["HOME"]!)/Developer/PlaydateSDK/"
    }

let package = Package(
    name: "CuddleKitDemo",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "CuddleKitDemo", type: xcode ? nil : .dynamic, targets: ["CuddleKitDemo"])
    ],
    dependencies: [
        .package(name: "CuddleKit", path: "../", traits: ["Playdate"]),
        .package(url: "https://source.marquiskurt.net/PDUniverse/PlaydateKit.git", branch: "main"),
        .package(url: "https://source.marquiskurt.net/PDUniverse/PDKUtils.git", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CuddleKitDemo",
            dependencies: [
                .product(name: "PlaydateKit", package: "PlaydateKit"),
                .product(name: "CuddleKit", package: "CuddleKit"),
                .product(name: "PDUIKit", package: "PDKUtils"),
            ],
            exclude: ["Resources"],
            swiftSettings: [
                .enableExperimentalFeature("Embedded"),
                .unsafeFlags([
                    "-whole-module-optimization",
                    "-Xfrontend", "-disable-objc-interop",
                    "-Xfrontend", "-disable-stack-protector",
                    "-Xfrontend", "-function-sections",
                    "-Xcc", "-DTARGET_EXTENSION",
                    "-Xcc", "-I", "-Xcc", "\(playdateSDKPath)/C_API",
                ]),
            ],
        )
    ]
)
