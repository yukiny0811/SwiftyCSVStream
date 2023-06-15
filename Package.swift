// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyCSVStream",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SwiftyCSVStream",
            targets: ["SwiftyCSVStream"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/dehesa/CodableCSV.git", .upToNextMajor(from: "0.6.7")),
        .package(url: "https://github.com/apple/swift-algorithms.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(
            name: "SwiftyCSVStream",
            dependencies: [
                "CodableCSV",
                .product(name: "Algorithms", package: "swift-algorithms")
            ]
        )
    ]
)
