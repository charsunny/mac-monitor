// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MacMonitor",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "MacMonitor",
            targets: ["MacMonitor"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "MacMonitor",
            dependencies: [],
            path: "MacMonitor"),
        .testTarget(
            name: "MacMonitorTests",
            dependencies: ["MacMonitor"],
            path: "Tests/MacMonitorTests"),
    ]
)
