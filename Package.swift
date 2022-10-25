// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "NFTHolic",
	platforms: [
		.macOS(.v12),
	],
	products: [
		.executable(name: "nftholic", targets: ["Main"])
	],
	dependencies: [
		.package(url: "https://github.com/generald/CollectionKit", branch: "master"),
		.package(url: "https://github.com/gonzalezreal/DefaultCodable", from: "1.2.1"),
		.package(url: "https://github.com/JohnSundell/Files", from: "4.2.0"),
		.package(url: "https://github.com/groue/GRDB.swift", from: "5.25.0"),
		.package(url: "https://github.com/fromkk/HashKit", from: "1.1.0"),
		.package(url: "https://github.com/crossroadlabs/Regex", from: "1.2.0"),
		.package(url: "https://github.com/jakeheis/SwiftCLI", from: "6.0.3"),
		.package(url: "https://github.com/thii/SwiftHEXColors", from: "1.4.1"),
		.package(url: "https://github.com/bitflying/SwiftKeccak.git", from: "0.1.0"),
		.package(url: "https://github.com/jpsim/Yams", from: "5.0.1"),
	],
	targets: [
		.executableTarget(
			name: "Main",
			dependencies: [
				"CleanCommand",
				"GenCommand",
			]),
		.target(
			name: "CleanCommand",
			dependencies: [
				"CommandCommon",
				"CollectionKit",
				"Files",
				"HashKit",
				"SwiftCLI",
			]),
		.target(
			name: "GenCommand",
			dependencies: [
				"CommandCommon",
				"Common",
				"GenCommandCommon",
				"ImageFactory",
				"LayerStrictionRegexFactory",
				"MetadataFactory",
				"RandomizationController",
				"CollectionKit",
				"Files",
				.product(name: "GRDB", package: "GRDB.swift"),
				"Regex",
				"SwiftCLI",
				"SwiftKeccak",
				"Yams",
			]),
		.target(
			name: "ImageFactory",
			dependencies: [
				"Common",
				"GenCommandCommon",
				"CollectionKit",
				"Files",
			]),
		.target(
			name: "LayerStrictionRegexFactory",
			dependencies: [
				"GenCommandCommon",
				"Files",
				"Regex",
			]),
		.target(
			name: "MetadataFactory",
			dependencies: [
				"Common",
				"GenCommandCommon",
				"CollectionKit",
				"Files",
				"Regex",
			]),
		.target(
			name: "RandomizationController",
			dependencies: [
				"GenCommandCommon",
				"CollectionKit",
				"Files",
				"Regex",
			]),
		.target(
			name: "GenCommandCommon",
			dependencies: [
				"DefaultCodable",
				"Files",
				"SwiftHEXColors",
			]),
		.target(
			name: "CommandCommon",
			dependencies: [
				"Files",
				"Regex",
				"SwiftCLI",
			]),
		.target(name: "Common"),
		.testTarget(
			name: "MainTests",
			dependencies: ["Main"]),
	]
)
