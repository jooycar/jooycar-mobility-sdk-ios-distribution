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
            url: "https://mobility-sdk.jooycar.net/ios/JooycarMobilitySDK-1.2.3-push2.xcframework.zip",
            checksum: "0a05d4ce0635f6dfe1f11716e7d14358846b76299be2b8d95128642d54ebc30f"
        ),
        .binaryTarget(
            name: "OctoProvider",
            url: "https://mobility-sdk.jooycar.net/ios/OctoProvider-1.2.3-push2.xcframework.zip",
            checksum: "571ddbe2ee9459b081fd5c7ee05f114578ad58d54ad94fa093d4dd83ba44943e"
        ),
        .binaryTarget(
            name: "TelematicsProvider",
            url: "https://mobility-sdk.jooycar.net/ios/TelematicsProvider-1.2.3-push2.xcframework.zip",
            checksum: "bedb5778bb60d0e0fe65cc55b0fdf38c3a27c21d7fa171126721f66ff66b5309"
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
