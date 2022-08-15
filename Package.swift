// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AptosSwift",
    platforms: [
        .macOS(.v10_12), .iOS(.v10)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AptosSwift",
            targets: ["AptosSwift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/mxcl/PromiseKit.git", from: "6.8.4"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.4.1"),
        .package(url: "https://github.com/lishuailibertine/tweetnacl-swiftwrap", from: "1.0.5"),
        .package(url: "https://github.com/Flight-School/AnyCodable.git", .exact("0.6.1")),
        .package(url: "https://github.com/mathwallet/BIP39swift", from: "1.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AptosSwift",
            dependencies: [
                "PromiseKit",
                "CryptoSwift",
                "AnyCodable",
                .product(name: "TweetNacl", package: "tweetnacl-swiftwrap"),
                "BIP39swift"
            ]
        ),
        .testTarget(
            name: "AptosSwiftTests",
            dependencies: ["AptosSwift"]),
    ]
)
