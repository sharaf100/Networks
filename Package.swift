// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Networks",
    platforms: [.macOS(.v10_15), .iOS(.v14), .watchOS(.v9)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Networks",
            targets: ["Networks"]),
    ],
    dependencies: [
        .package(path: "../MdlTransferHolder"),
        .package(url: "https://github.com/Moya/Moya", from: "15.0.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Networks", dependencies: [
                "Moya",
               "MdlTransferHolder"
            ]),
        
        .testTarget(
            name: "NetworksTests",
            dependencies: ["Networks"]
        ),
    ]
    
)
