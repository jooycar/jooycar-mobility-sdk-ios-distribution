// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "JooycarMobilitySDK",
    // iOS 15 y Swift 6.4 los exige JooycarTelematics; SwiftPM los aplica a todo el paquete.
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "JooycarMobilitySDK",
            targets: ["JooycarMobilitySDKDependencyWrapper"]
        ),
        // Proveedores de telemática: la app enlaza uno solo.
        .library(
            name: "OctoProvider",
            targets: ["OctoProviderDependencyWrapper"]
        ),
        .library(
            name: "TelematicsProvider",
            targets: ["TelematicsProviderDependencyWrapper"]
        ),
    ],
    dependencies: [
        .package(id: "drivekit.spm", exact: "3.9.4"),
        .package(url: "https://github.com/jooycar/jooycar-telematics-sdk-ios-distribution.git", exact: "0.3.1-dev"),
        .package(url: "https://github.com/amplitude/Amplitude-Swift.git", exact: "1.18.5"),
        .package(url: "https://github.com/amplitude/AmplitudeSessionReplay-iOS.git", exact: "0.16.0"),
        .package(url: "https://github.com/amplitude/analytics-connector-ios.git", exact: "1.3.0"),
        // Render de imágenes universales (JooycarImageView, desde 1.0.3):
        // Lottie para animaciones JSON/.lottie y SVGView para vectores.
        .package(url: "https://github.com/airbnb/lottie-ios.git", exact: "4.6.1"),
        .package(url: "https://github.com/exyte/SVGView.git", exact: "1.0.6"),
    ],
    targets: [
        // CircleCI actualiza url y checksum de cada binaryTarget en cada release.
        .binaryTarget(
            name: "JooycarMobilitySDK",
            url: "https://mobility-sdk.jooycar.net/ios/JooycarMobilitySDK-1.3.0-beta3.xcframework.zip",
            checksum: "53ffd81965c6e818f8e1d543cd18fd18d729ffa9428fd3ed1f6b550b84e26c6d"
        ),
        .binaryTarget(
            name: "OctoProvider",
            url: "https://mobility-sdk.jooycar.net/ios/OctoProvider-1.3.0-beta3.xcframework.zip",
            checksum: "9d61e24d387840bb476e305b9c356e93b634ad906209a010176369c737d851e8"
        ),
        .binaryTarget(
            name: "TelematicsProvider",
            url: "https://mobility-sdk.jooycar.net/ios/TelematicsProvider-1.3.0-beta3.xcframework.zip",
            checksum: "c4d2937cd3ded14afc81630e2c436991f2aa05027a074ab03a95dd5457f9b432"
        ),
        .target(
            name: "JooycarMobilitySDKDependencyWrapper",
            dependencies: [
                .product(name: "AmplitudeSwift", package: "Amplitude-Swift"),
                .product(name: "AmplitudeSessionReplay", package: "AmplitudeSessionReplay-iOS"),
                .product(name: "AmplitudeSwiftSessionReplayPlugin", package: "AmplitudeSessionReplay-iOS"),
                .product(name: "AnalyticsConnector", package: "analytics-connector-ios"),
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "SVGView", package: "SVGView"),
                .target(name: "JooycarMobilitySDK"),
            ],
            path: "Sources/JooycarMobilitySDKDependencyWrapper"
        ),
        .target(
            name: "OctoProviderDependencyWrapper",
            dependencies: [
                .product(name: "DriveKit", package: "drivekit.spm"),
                .target(name: "JooycarMobilitySDKDependencyWrapper"),
                .target(name: "OctoProvider"),
            ],
            path: "Sources/OctoProviderDependencyWrapper"
        ),
        .target(
            name: "TelematicsProviderDependencyWrapper",
            dependencies: [
                .product(name: "JooycarTelematics", package: "jooycar-telematics-sdk-ios-distribution"),
                .target(name: "JooycarMobilitySDKDependencyWrapper"),
                .target(name: "TelematicsProvider"),
            ],
            path: "Sources/TelematicsProviderDependencyWrapper"
        ),
    ]
)
