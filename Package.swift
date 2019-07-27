// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import Foundation
import PackageDescription

let package = Package(
    name: "Retro",
    platforms: [.macOS(.v10_12)],
    products: [
        .library(
            name: "Retro",
            targets: ["Retro"]),
        .executable(
            name: "RetroExperiments",
            targets: ["RetroExperiments"]),
    ],
    dependencies: [
        .package(url: "https://github.com/eaplatanios/swift-rl.git", .branch("master")),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/1024jp/GzipSwift.git", from: "4.1.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .branch("master"))
    ],
    targets: [
        .systemLibrary(
          name: "CRetro",
          path: "Sources/CRetro",
          pkgConfig: "retro-c"),
        .target(
            name: "Retro",
            dependencies: ["CRetro", "ReinforcementLearning", "Gzip", "ZIPFoundation"],
            path: "Sources/Retro"),
        .target(
            name: "RetroExperiments",
            dependencies: ["Logging", "Retro", "ReinforcementLearning"],
            path: "Sources/RetroExperiments"),
        .testTarget(
            name: "RetroTests",
            dependencies: ["Retro"])
    ]
)
