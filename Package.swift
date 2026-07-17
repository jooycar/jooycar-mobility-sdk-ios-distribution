// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "JooycarMobilitySDK",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "JooycarMobilitySDK",
            targets: ["JooycarMobilitySDKDependencyWrapper"]
        )
    ],
    dependencies: [
        .package(id: "drivekit.spm", exact: "3.9.0"),
        .package(url: "https://github.com/amplitude/Amplitude-Swift.git", exact: "1.18.1"),
        .package(url: "https://github.com/amplitude/AmplitudeSessionReplay-iOS.git", exact: "0.10.0"),
        .package(url: "https://github.com/amplitude/analytics-connector-ios.git", exact: "1.3.0"),
        // Render de imágenes universales (JooycarImageView, desde 1.0.3):
        // Lottie para animaciones JSON/.lottie y SVGView para vectores.
        .package(url: "https://github.com/airbnb/lottie-ios.git", exact: "4.6.1"),
        .package(url: "https://github.com/exyte/SVGView.git", exact: "1.0.6"),
    ],
    targets: [
        .binaryTarget(
            name: "JooycarMobilitySDK",
            url: "https://mobility-sdk.jooycar.net/ios/JooycarMobilitySDK-1.0.6.xcframework.zip",
            checksum: "e796756dbdb7b1cb3800927f8b6d60c804119e1c3fa992c030a60b5f20d979e5"
        ),
        .target(
            name: "JooycarMobilitySDKDependencyWrapper",
            dependencies: [
                .product(name: "DriveKit", package: "drivekit.spm"),
                .product(name: "AmplitudeSwift", package: "Amplitude-Swift"),
                .product(name: "AmplitudeSessionReplay", package: "AmplitudeSessionReplay-iOS"),
                .product(name: "AmplitudeSwiftSessionReplayPlugin", package: "AmplitudeSessionReplay-iOS"),
                .product(name: "AnalyticsConnector", package: "analytics-connector-ios"),
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "SVGView", package: "SVGView"),
                .target(name: "JooycarMobilitySDK"),
            ],
            path: "Sources/JooycarMobilitySDKDependencyWrapper"
        )
    ]
)
