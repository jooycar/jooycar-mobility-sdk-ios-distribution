// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "JooycarMobilitySDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "JooycarMobilitySDK",
            targets: ["JooycarMobilitySDKWrapper"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "JooycarMobilitySDK",
            url: "https://mobility-sdk.jooycar.net/ios/JooycarMobilitySDK-1.0.0-beta3.xcframework.zip",
            checksum: "8e3f59b002718d7c9d68246d790bc8acf96e3de4f7ecb577d5ed2e43eb21b49e"
        )
        .target(
            name: "JooycarMobilitySDKWrapper",
            dependencies: [
                "JooycarMobilitySDK",
                .product(name: "DriveKit", package: "drivekit.spm")
            ],

        )
    ]
)

