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
				"CompletionCommand",
				"EnchantCommand",
				"SummonCommand",
			]),
		.target(
			name: "CleanCommand",
			dependencies: [
				"CollectionKit",
				"CommandCommon",
				"Files",
				"HashKit",
				"SwiftCLI",
			]),
		.target(
			name: "CompletionCommand",
			dependencies: [
				"SwiftCLI",
			]),
		.target(
			name: "EnchantCommand",
			dependencies: [
				"AssetConfig",
				"AssetConfigLoader",
				"CollectionKit",
				"CommandCommon",
				"ExifReader",
				"Files",
				"MetadataFactory",
				"SwiftCLI",
				"SingleAssetElectionStore",
				"SingleAssetSequence",
				"TokenFileNameFactory",
			]),
		.target(
			name: "SummonCommand",
			dependencies: [
				"AssetConfig",
				"AssetConfigLoader",
				"CollectionKit",
				"CommandCommon",
				"Files",
				"SummonCommandCommon",
				"ImageFactory",
				"LayerConstraint",
				"MetadataFactory",
				"RandomizationController",
				"RecipeStore",
				"SwiftCLI",
				"SwiftHEXColors",
				"TokenFileNameFactory",
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
		.target(name: "ExifReader"),
		.target(
			name: "SummonCommandCommon",
			dependencies: [
				"Files",
			]),
		.target(
			name: "ImageFactory",
			dependencies: [
				"SummonCommandCommon",
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
				"SummonCommandCommon",
				"Files",
				.product(name: "GRDB", package: "GRDB.swift"),
			]),
		.target(
			name: "TokenFileNameFactory",
			dependencies: [
				"SwiftKeccak",
			]),
		.target(
			name: "SingleAssetElectionStore",
			dependencies: [
				"Files",
				.product(name: "GRDB", package: "GRDB.swift"),
			]),
		.target(
			name: "SingleAssetSequence",
			dependencies: [
				"AssetConfig",
				"CollectionKit",
				"Files",
			]),
	]
)
