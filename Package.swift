// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NFT Holic",
	platforms: [
		.macOS(.v12),
	],
    dependencies: [
		.package(url: "https://github.com/generald/CollectionKit", branch: "master"),
		.package(url: "https://github.com/gonzalezreal/DefaultCodable", from: "1.2.1"),
		.package(url: "https://github.com/JohnSundell/Files", from: "4.2.0"),
		.package(url: "https://github.com/fromkk/HashKit.git", from: "1.1.0"),
		.package(url: "https://github.com/crossroadlabs/Regex", from: "1.2.0"),
		.package(url: "https://github.com/jakeheis/SwiftCLI", from: "6.0.3"),
		.package(url: "https://github.com/thii/SwiftHEXColors.git", from: "1.4.1"),
		
    ],
    targets: [
        .executableTarget(
            name: "NFT Holic",
			dependencies: ["CollectionKit", "DefaultCodable", "Files", "HashKit", "Regex", "SwiftCLI", "SwiftHEXColors"]),
        .testTarget(
            name: "NFT HolicTests",
            dependencies: ["NFT Holic"]),
    ]
)
