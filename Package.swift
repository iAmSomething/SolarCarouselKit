// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SolarCarouselKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SolarCarouselKit",
            targets: ["SolarCarouselKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/nalexn/ViewInspector", from: "0.9.11")
    ],
    targets: [
        .target(
            name: "SolarCarouselKit",
            path: "Sources/SolarCarouselKit",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "SolarCarouselKitTests",
            dependencies: [
                "SolarCarouselKit",
                .product(name: "ViewInspector", package: "ViewInspector")
            ],
            path: "Tests/SolarCarouselKitTests"
        )
    ]
)
