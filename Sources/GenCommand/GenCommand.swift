import CommandCommon
import GenCommandCommon
import ImageFactory
import LayerStrictionRegexFactory
import MetadataFactory
import RandomizationController
import TokenFileNameFactory
import AppKit
import CollectionKit
import Files
import Foundation
import GRDB
import Regex
import SwiftCLI
import UniformTypeIdentifiers
import Yams

public class GenCommand: Command {

	// MARK: - Arguments

	@Param(completion: .filename)
	var inputFolder: Folder

	@Key("-o", "--output-dir", description: "Output destination (default is ~/Documents/NFTs/{inputFolder name})", completion: .filename)
	var outputFolder: Folder!

	@Key("--image-foldername", description: "Folder name to place images (default is images)", completion: .filename)
	var imageFolderName: String!

	@Key("--name-format", description: "Image and metadata file name format without extension (default is %d)", validation: [.formatInteger()])
	var fileNameFormat: String!

	@Flag("-k", "--hashed-name", description: "Use hashed file names (keccak256)")
	var hashFileName: Bool

	@Key("-q", "--quantity", description: "Number of creation (default is 100)", completion: .none, validation: [.greaterThan(0)])
	var creationCount: Int!

	@Key("-s", "--start-index", description: "Auto incremented index start from what? (default is 1)", completion: .none, validation: [.greaterThanOrEqual(0)])
	var startIndex: Int!

	@Key("-d", "--anim-duration", description: "Animation duration in seconds (default is 2.0000)", completion: .none, validation: [.greaterThan(0)])
	var animationDuration: Double!

	@Key("-r", "--reprint", description: "Reprint images based on data.sqlite file", completion: .filename)
	var sqliteFile: File?

	@Key("-t", "--type", description: "Type to generate image (default is gif)", completion: .values([(name: "gif", description: ""), (name: "png", description: "")]), validation: [.custom("unsupported image type") { $0 == .gif || $0 == .png }])
	var imageType: UTType!

	@Flag("-f", "--overwrite", description: "Overwrite existing files")
	var forceOverwrite: Bool

	@Flag("--without-metadata", description: "Not to generate metadata")
	var noMetadata: Bool

	@Flag("--without-image", description: "Not to generate image")
	var noImage: Bool

	@Flag("--sample", description: "Generate image with watermark (Not for sales)")
	var isSampleMode: Bool

	// MARK: - Command Implementations
	
	public let name = "summon"
	public let shortDescription = "Generate many NFTs"

	private lazy var nameFactory = TokenFileNameFactory(nameFormat: fileNameFormat, hash: hashFileName)

	public init() {}

	public var optionGroups: [OptionGroup] {
		[.atMostOne($noMetadata, $noImage)]
	}

	public func execute() throws {
		configureArguments()

		let results = try generate()
		logging(results: results)
	}
}

private extension GenCommand {

	// MARK: - Configure Default Values
	func configureArguments() {
		configureOutputFolder()
		configureImageFolderName()
		configureFileNameFormat()
		configureCreationCount()
		configureStartIndex()
		configureAnimationDuration()
		configureImageType()
	}

	func configureOutputFolder() {
		guard outputFolder == nil, let defaultFolder = try? Folder.documents?.createSubfolderIfNeeded(withName: "NFTs").createSubfolderIfNeeded(withName: inputFolder.name) else { return }
		$outputFolder.update(to: defaultFolder)
		stdout <<< "--output-dir is not specified. Automatically set to: \(defaultFolder.path)"
		NSWorkspace.shared.open(defaultFolder.url)
	}

	func configureImageFolderName() {
		guard imageFolderName == nil else { return }
		$imageFolderName.update(to: "images")
	}

	func configureFileNameFormat() {
		guard fileNameFormat == nil else { return }
		$fileNameFormat.update(to: "%d")
	}

	func configureCreationCount() {
		guard creationCount == nil else { return }
		$creationCount.update(to: 100)
	}

	func configureStartIndex() {
		guard startIndex == nil else { return }
		$startIndex.update(to: 1)
	}

	func configureAnimationDuration() {
		guard animationDuration == nil else { return }
		$animationDuration.update(to: 2)
	}

	func configureImageType() {
		guard imageType == nil else { return }
		$imageType.update(to: .gif)
	}

	// MARK: - Generate

	func generate() throws -> [Bool] {
		// measure time
		let startDate = Date()
		defer { stdout <<< "Generating many images took \(Date().timeIntervalSince(startDate)) seconds." }

		let config = loadAssetConfig()
		let regexFactory = LayerStrictionRegexFactory(layerStrictions: config.combinations)
		let randomManager = RandomizationController(config: config.randomization)
		let layerFolders = sort(subjects: inputFolder.subfolders, where: \.nameExcludingExtension, order: config.order?.selection)

		func inputData<F: Location, S: Sequence>(locations: (Folder) -> S) -> InputData where F: Hashable, S.Element == F {
			let layers = layerFolders
				.reduce(into: [InputData.ImageLayer<F>]()) { layers, layerFolder in
					let limitRegex = regexFactory.validItemNameRegex(forLayer: layerFolder.name, conditionLayers: layers)
					let candidates = locations(layerFolder).filter({ f in
						guard let regex = limitRegex else { return true } // no limitation
						return f.nameExcludingExtension =~ regex
					})
					guard let elected = randomManager.elect(from: candidates, targetLayer: layerFolder.name) else { return }
					layers.append(.init(imageLocation: elected.element, layer: layerFolder.name, name: elected.element.nameExcludingExtension, probability: elected.probability))
				}

			// arrange layers in the order of depth configured in json
			let sortedLayers = sort(subjects: layers, where: \.layer, order: config.order?.layerDepth)

			let serialText = InputData.SerialText(from: config.drawSerial, inputFolder: inputFolder)
			let assets: InputData.Assets
			switch sortedLayers {
			case let (folders as [InputData.ImageLayer<Folder>]) as Any:
				assets = .animated(layers: folders, duration: animationDuration)
			case let (files as [InputData.ImageLayer<File>]) as Any:
				assets = .still(layers: files)
			default:
				exit(1)
			}
			return InputData(assets: assets, serialText: serialText, isSampleMode: isSampleMode)
		}

		let animated = isAnimatedAsset

		let inputDatabaseQueue = try sqliteFile.map { file in try DatabaseQueue(path: file.path) }
		defer { try? inputDatabaseQueue?.close() }

		let outputDatabaseQueue = try DatabaseQueue(path: "\(outputFolder.path)/data.sqlite")
		_ = try outputDatabaseQueue.inDatabase(OutputRecipe.createTable(in:))
		defer { try? outputDatabaseQueue.close() }

		return try indices.map { index -> Bool in
			// measure time
			let startDate = Date()
			defer { stdout <<< "Generating an image took \(Date().timeIntervalSince(startDate)) seconds." }

			// load reprint data if db file passed
			let recipe = try inputDatabaseQueue?.inDatabase(OutputRecipe.filter(id: Int64(index)).fetchOne)
			let inputAssets = recipe?.assets(isAnimated: animated, animationDuration: animationDuration, inputFolder: inputFolder)
			let reprintData = inputAssets.map { InputData(assets: $0, serialText: .init(from: config.drawSerial, inputFolder: inputFolder), isSampleMode: isSampleMode) }

			// load reprint data or create new
			let input = reprintData ?? (animated ? inputData(locations: \.subfolders) : inputData(locations: \.files))
			// write to db
			try outputDatabaseQueue.inDatabase(OutputRecipe(serial: index, source: input, inputFolder: inputFolder).save)
			// generate image and metadata
			return generateImage(input: input, index: index) && generateMetadata(input: input, index: index, config: config.metadata)
		}
	}

	@discardableResult
	func generateImage(input: InputData, index: Int) -> Bool {
		guard !noImage else { return true }
		guard let imageFolder = try? outputFolder.createSubfolderIfNeeded(withName: imageFolderName) else {
			stderr <<< "Couldn't create root folder to store images"
			return false
		}
		let imageFactory = ImageFactory(input: input)
		switch imageFactory.generateImage(saveIn: imageFolder, as: nameFactory.fileName(from: index), serial: index, imageType: imageType) {
		case let .success(file):
			stdout <<< "Created: \(file.path)"
			return true
		case let .failure(error):
			switch error {
			case .noImage:
				stderr <<< "Couldn't create image."
			case .unsupportedImageType:
				stderr <<< "Unsupported image type."
			case .creatingFileFailed:
				stderr <<< "Couldn't create file to write image."
			case .finalizeImageFailed:
				stderr <<< "Couldn't finalize an image."
			}
			return false
		}
	}

	@discardableResult
	func generateMetadata(input: InputData, index: Int, config: AssetConfig.Metadata?) -> Bool {
		guard !noMetadata, let metadataConfig = config else { return true }
		let metadataFactory = MetadataFactory(input: input)
		switch metadataFactory.generateMetadata(saveIn: outputFolder, as: nameFactory.fileName(from: index), serial: index, metadataConfig: metadataConfig, imageFolderName: imageFolderName, imageType: imageType) {
		case let .success(file):
			stdout <<< "Created: \(file.path)"
			return true
		case let .failure(error):
			switch error {
			case .creatingFileFailed:
				stderr <<< "Couldn't create file to write metadata."
			case .imageUrlFormatIsRequired:
				stderr <<< "imageUrlFormat is required field in JSON."
			case .invalidMetadataSortConfig:
				stderr <<< "Sorting metadata config should cover all trait you defined."
			case .invalidBackgroundColorCode:
				stderr <<< "backgroundColor in metadata should be 3 or 6 hex code without # prefix."
			case .writingFileFailed:
				stderr <<< "Writing metadata failed."
			}
			return false
		}
	}

	// MARK: - Load Config File

	func loadAssetConfig() -> AssetConfig {
		guard let file = inputFolder.files.first(where: { $0.nameExcludingExtension == "config" }) else {
			stderr <<< "Config file not found in \(inputFolder.name)"
			stdout <<< "But still ok! We can continue processing..."
			return .empty
		}

		do {
			switch file.extension {
			case "yml", "yaml":
				return try YAMLDecoder().decode(AssetConfig.self, from: file.read())
			case "json":
				return try JSONDecoder().decode(AssetConfig.self, from: file.read())
			default:
				stderr <<< "Incompatible file extension: \(file.name)"
				stdout <<< "But still ok! We can continue processing..."
				return .empty
			}
		} catch {
			stderr <<< "No valid config file!"
			stdout <<< "But still ok! We can continue processing..."
			return .empty
		}
	}

	// MARK: - Utilities

	// Detect if it's expected to be animated image from input folder structure
	var isAnimatedAsset: Bool {
		let subfolders = inputFolder.subfolders.array
		let isStillAssetEmpty = subfolders.all(\.files.array.isEmpty)
		let isAnimatedAssetEmpty = subfolders.all(\.subfolders.array.isEmpty)
		// check XOR is true
		guard isStillAssetEmpty != isAnimatedAssetEmpty else {
			stderr <<< "Invalid input folder structure."
			exit(1)
		}
		return isStillAssetEmpty
	}

	/// Indices of images to create. They start from 1, not 0.
	var indices: [Int] {
		let skips = forceOverwrite
		? []
		: outputFolder.files.map(\.nameExcludingExtension)

		return (startIndex..<(startIndex + creationCount))
			.map { index in (index, nameFactory.fileName(from: index)) }
			.unless { _, fileName in skips.contains(fileName) }
			.map(\.0)
	}

	func sort<Subjects: Sequence>(subjects: Subjects, where: (Subjects.Element) -> String, order: [String]?) -> [Subjects.Element] {
		let array = subjects.array
		let sortedAlphabetically = array.sorted(at: `where`, by: <)
		guard let order = order else { return sortedAlphabetically }
		let result = order.compactMap { name in
			subjects.first { subject in
				`where`(subject) == name
			}
		}
		let notFoundInOrder = Set(subjects.map(`where`)).subtracting(order)
		guard notFoundInOrder.isEmpty else {
			stderr <<< "Not found in order config: \(notFoundInOrder.joined(separator: ", "))"
			return result
		}
		return result
	}

	// MARK: - Logging

	func logging(results: [Bool]) {
		let successCount = results.filter { $0 }.count
		stdout <<< "\(successCount) images have been generated!"

		let failureCount = results.filter(!).count
		guard failureCount > 0 else {
			stdout <<< "Finish gracefully!"
			return
		}
		stderr <<< "Failed to generate \(failureCount) images..."
	}
}
