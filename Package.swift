// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ApolloGenerator",
    products: [
           .executable(name: "apolloGenerator", targets: ["ApolloGenerator"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1")
    ],
    targets: [
        .target(name: "ApolloGenerator", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser")]
        ),
    ]
)
