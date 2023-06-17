// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "ULID.swift",
    products: [
        .library(name: "ULID", targets: ["ULID"]),
    ],
    targets: [
        .target(name: "ULID"),
        .testTarget(name: "ULIDTests", dependencies: ["ULID"]),
    ]
)
