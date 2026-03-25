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
            url: "https://mobility-sdk.jooycar.net/ios/JooycarMobilitySDK-1.0.0-beta4.xcframework.zip",
            checksum: "48dd3c89eb9aefa91269c936ffc7d2c0a20d47c8dcc47062aa7300d0f307bef6"
        )
    ]
)

