// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ULID.swift",
    products: [
        .library(name: "ULID", targets: ["ULID"])
    ],
    targets: [
        .target(name: "ULID"),
        .testTarget(name: "ULIDTests", dependencies: ["ULID"])
    ]
)
