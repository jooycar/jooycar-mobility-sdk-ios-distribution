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
        .package(url: "https://github.com/amplitude/Amplitude-Swift.git", from: "1.18.1"),
        .package(url: "https://github.com/amplitude/AmplitudeSessionReplay-iOS.git", from: "0.10.0"),
        // Pineado a 1.3.0: la 1.3.1 dispara un bug del verificador de .swiftinterface
        // con Swift 6.2/Xcode 26.1 al hacer archive con BUILD_LIBRARY_FOR_DISTRIBUTION=YES.
        .package(url: "https://github.com/amplitude/analytics-connector-ios.git", exact: "1.3.0"),
    ],
    targets: [
        .binaryTarget(
            name: "JooycarMobilitySDK",
            url: "https://mobility-sdk.jooycar.net/ios/JooycarMobilitySDK-1.0.0-beta24.xcframework.zip",
            checksum: "c092c9d25b6f673962c7bf165fb1c4c2a3bc44fe91685510c456b6adc595457b"
        ),
        .target(
            name: "JooycarMobilitySDKDependencyWrapper",
            dependencies: [
                .product(name: "DriveKit", package: "drivekit.spm"),
                .product(name: "AmplitudeSwift", package: "Amplitude-Swift"),
                .product(name: "AmplitudeSessionReplay", package: "AmplitudeSessionReplay-iOS"),
                .product(name: "AmplitudeSwiftSessionReplayPlugin", package: "AmplitudeSessionReplay-iOS"),
                .target(name: "JooycarMobilitySDK"),
            ],
            path: "Sources/JooycarMobilitySDKDependencyWrapper"
        )
    ]
)
