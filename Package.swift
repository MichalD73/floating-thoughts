// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "FloatingThoughts",
    defaultLocalization: "cs",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "FloatingThoughts",
            targets: ["FloatingThoughts"]
        )
    ],
    dependencies: [
        .package(name: "Firebase", path: "External/firebase-ios-sdk")
    ],
    targets: [
        .executableTarget(
            name: "FloatingThoughts",
            dependencies: [
                .product(name: "FirebaseFirestore", package: "Firebase"),
                .product(name: "FirebaseStorage", package: "Firebase")
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .define("FIREBASE_SWIFT_PACKAGE")
            ]
        ),
        .testTarget(
            name: "FloatingThoughtsTests",
            dependencies: ["FloatingThoughts"]
        )
    ]
)
