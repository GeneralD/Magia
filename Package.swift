// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Magia",
	platforms: [
		.macOS(.v13),
	],
	products: [
		.executable(name: "magia", targets: ["Main"])
	],
	dependencies: [
		.package(url: "https://github.com/generald/CollectionKit", branch: "master"),
		.package(url: "https://github.com/gonzalezreal/DefaultCodable", from: "1.2.1"),
		.package(url: "https://github.com/JohnSundell/Files", from: "4.2.0"),
		.package(url: "https://github.com/groue/GRDB.swift", from: "5.25.0"),
		.package(url: "https://github.com/fromkk/HashKit", from: "1.1.0"),
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
				"EnchantCommand",
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
			name: "EnchantCommand",
			dependencies: [
				"CommandCommon",
				"Files",
				"SwiftCLI",
				"TokenFileNameFactory",
			]),
		.target(
			name: "GenCommand",
			dependencies: [
				"AssetConfig",
				"AssetConfigLoader",
				"CommandCommon",
				"GenCommandCommon",
				"ImageFactory",
				"LayerConstraint",
				"MetadataFactory",
				"RandomizationController",
				"RecipeStore",
				"TokenFileNameFactory",
				"CollectionKit",
				"Files",
				"SwiftCLI",
				"SwiftHEXColors",
			]),
		.target(name: "AssetConfig"),
		.target(
			name: "AssetConfigLoader",
			dependencies: [
				"AssetConfig",
				"DefaultCodable",
				"Yams",
			]),
		.target(
			name: "CommandCommon",
			dependencies: [
				"Files",
				"SwiftCLI",
			]),
		.target(
			name: "GenCommandCommon",
			dependencies: [
				"Files",
			]),
		.target(
			name: "ImageFactory",
			dependencies: [
				"GenCommandCommon",
				"CollectionKit",
				"Files",
			]),
		.target(
			name: "LayerConstraint",
			dependencies: [
				"AssetConfig",
			]),
		.target(
			name: "MetadataFactory",
			dependencies: [
				"AssetConfig",
				"CollectionKit",
				"Files",
			]),
		.target(
			name: "RandomizationController",
			dependencies: [
				"AssetConfig",
				"CollectionKit",
				"Files",
			]),
		.target(
			name: "RecipeStore",
			dependencies: [
				"GenCommandCommon",
				"Files",
				.product(name: "GRDB", package: "GRDB.swift"),
			]),
		.target(
			name: "TokenFileNameFactory",
			dependencies: [
				"SwiftKeccak",
			]),
		.testTarget(
			name: "MainTests",
			dependencies: ["Main"]),
	]
)
