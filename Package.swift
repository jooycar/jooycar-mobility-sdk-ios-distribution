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
        .package(url: "https://github.com/jooycar/jooycar-telematics-sdk-ios-distribution.git", exact: "0.2.2-dev"),
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
            url: "https://mobility-sdk.jooycar.net/ios/JooycarMobilitySDK-1.2.3-push1.xcframework.zip",
            checksum: "0f5af8ff3da1587dab8ec3a0ef5444e185023ae776ae3b6e370ae05ae76227c3"
        ),
        .binaryTarget(
            name: "OctoProvider",
            url: "https://mobility-sdk.jooycar.net/ios/OctoProvider-1.2.3-push1.xcframework.zip",
            checksum: "79ece7393132ab6caa5a238828cd4cfe07c87ac32d1e7574c3ac1b911c5bcbe0"
        ),
        .binaryTarget(
            name: "TelematicsProvider",
            url: "https://mobility-sdk.jooycar.net/ios/TelematicsProvider-1.2.3-push1.xcframework.zip",
            checksum: "14453ce83b132af3a41f1d43eced07ebba7dc0dfaa17102610079e9a06b82d00"
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
