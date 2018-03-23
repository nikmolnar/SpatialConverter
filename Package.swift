// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SpatialConverter",
    dependencies: [
        .package(
            url: "https://github.com/PerfectlySoft/Perfect-PostgreSQL.git",
            Version(3,0,0) ..< Version(4,0,0)
        )
    ],
    targets: []
)
