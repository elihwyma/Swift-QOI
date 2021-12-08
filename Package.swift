// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftQOI",
    products: [
        .library(
            name: "SwiftQOI",
            targets: ["SwiftQOI"]),
    ],
    targets: [
        .systemLibrary(name: "SQOI", path: "Sources/SQOI"),
        .target(
            name: "SwiftQOI",
            dependencies: ["SQOI"],
            path: "Sources/Swift-QOI")
    ]
)
