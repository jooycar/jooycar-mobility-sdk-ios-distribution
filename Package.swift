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
            targets: ["JooycarMobilitySDK"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "JooycarMobilitySDK",
            url: "https://mobility-sdk.jooycar.net/ios/JooycarMobilitySDK-1.0.0-beta10.xcframework.zip",
            checksum: "aacba6943bc379c10f56cd310cf60583a62632bf5e7fdd3340f62c1f01ce688b"
        )
    ]
)

