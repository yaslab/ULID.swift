// swift-tools-version: 5.4

import PackageDescription

let package = Package(
    name: "ULID.swift", 
    platforms: [
        .iOS(.v12), .tvOS(.v12), .watchOS(.v4), .macOS(.v10_13)
    ],
    products: [
        .library(name: "ULID", targets: ["ULID"]),
    ],
    targets: [
        .target(name: "ULID"),
        .testTarget(name: "ULIDTests", dependencies: ["ULID"]),
    ]
)
