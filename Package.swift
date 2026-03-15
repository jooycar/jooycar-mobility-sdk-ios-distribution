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
            name:"JooycarMobilitySDK",
            url:"https://mobility-sdk.jooycar.net/ios/JooycarMobilitySDK.xcframework.zip",
            checksum: "a65629bcab31da38430725078d99b2e68b11ec8bcea793e0a53c220c92b9523a"
        )
    ]
)

