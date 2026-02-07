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
        .package(url: "https://github.com/danielgindi/Charts.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "MacMonitor",
            dependencies: [
                .product(name: "DGCharts", package: "Charts")
            ],
            path: "MacMonitor"),
        .testTarget(
            name: "MacMonitorTests",
            dependencies: ["MacMonitor"],
            path: "Tests/MacMonitorTests"),
    ]
)
