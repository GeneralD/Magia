import CollectionKit
import Files
import Foundation
import Regex
import SwiftCLI
import Yams
import GRDB

class GenCommand: Command {
	let name = "gen"
	let shortDescription = "Generate your animated NFT"

	@Param(completion: .filename)
	var inputFolder: Folder

	@Key("-o", "--output-dir", description: "Output destination is required", completion: .filename)
	var outputFolder: Folder!

	@Key("-q", "--quantity", description: "Number of creation (default is 100)", completion: .none, validation: [.greaterThan(0)])
	var creationCount: Int?

	@Key("-s", "--start-index", description: "Auto incremented index start from what? (default is 1)", completion: .none, validation: [.greaterThan(0)])
	var startIndex: Int?

	@Key("-d", "--anim-duration", description: "Animation duration in seconds (default is 2.0000)", completion: .none, validation: [.greaterThan(0)])
	var animationDuration: Double?

	@Key("-r", "--reprint", description: "Reprint images based on data.sqlite file", completion: .filename)
	var sqliteFile: File?

	@Flag("-p", "--png", description: "Make png instead of gif")
	var isPng: Bool

	@Flag("-f", "--overwrite", description: "Overwrite existing files")
	var forceOverwrite: Bool

	@Flag("--without-metadata", description: "Not to generate metadata")
	var noMetadata: Bool

	@Flag("--sample", description: "Generate image with watermark (Not for sales)")
	var isSampleMode: Bool

	func execute() throws {
		// validate
		guard outputFolder != nil else {
			stdout <<< "--output-dir is required"
			return
		}

		let results = try generate()
		logging(results: results)
	}
}

private extension GenCommand {
	func generate() throws -> [Bool] {
		// measure time
		let startDate = Date()
		defer { stdout <<< "Generating many images took \(Date().timeIntervalSince(startDate)) seconds." }

		let config = loadAssetConfig()
		let regexFactory = LayerStrictionRegexFactory(layerStrictions: config.combinations)
		let randomManager = RamdomizationController(config: config.randomization)
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

			let serialText = InputData.SerialText(from: config.drawSerial)
			let assets: InputData.Assets
			switch sortedLayers {
			case let (folders as [InputData.ImageLayer<Folder>]) as Any:
				assets = .animated(layers: folders, duration: animationDuration ?? 2)
			case let (files as [InputData.ImageLayer<File>]) as Any:
				assets = .still(layers: files)
			default:
				exit(1)
			}
			return InputData(assets: assets, serialText: serialText, isSampleMode: isSampleMode)
		}

		let animated = isAnimated

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
			let inputAssets = recipe?.assets(isAnimated: isAnimated, animationDuration: animationDuration ?? 2, inputFolder: inputFolder)
			let reprintData = inputAssets.map { InputData(assets: $0, serialText: .init(from: config.drawSerial), isSampleMode: isSampleMode) }

			// load reprint data or create new
			let input = reprintData ?? (animated ? inputData(locations: \.subfolders) : inputData(locations: \.files))
			// write to db
			try outputDatabaseQueue.inDatabase(OutputRecipe(serial: index, source: input, inputFolder: inputFolder).save)
			// generate image and metadata
			return generateImage(input: input, index: index) && generateMetadata(input: input, index: index, config: config.metadata)
		}
	}

	// Detect if it's expected to be animated image from input folder structure
	var isAnimated: Bool {
		let subfolders = inputFolder.subfolders.array
		if subfolders.all(\.files.array.isEmpty), subfolders.any(\.subfolders.array.isEmpty.not) {
			return true // animated
		}
		if subfolders.any(\.files.array.isEmpty.not), subfolders.all(\.subfolders.array.isEmpty) {
			return false // still
		}
		stderr <<< "Invalid input folder structure."
		exit(1)
	}

	/// Indices of images to create. They start from 1, not 0.
	var indices: Set<Int> {
		let skips = forceOverwrite
		? []
		: outputFolder.files
			.map(\.nameExcludingExtension)
			.compactMap(Int.init)

		let loopCount = creationCount ?? 100

		let start = startIndex ?? 1
		let end = start + loopCount
		return Set(start..<end).subtracting(skips)
	}

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

	@discardableResult
	func generateImage(input: InputData, index: Int) -> Bool {
		let imageFactory = ImageFactory(input: input)
		switch imageFactory.generateImage(saveIn: outputFolder, serial: index, isPng: isPng) {
		case let .success(file):
			stdout <<< "Created: \(file.path)"
			return true
		case let .failure(error):
			switch error {
			case .noImage:
				stderr <<< "Couldn't create image."
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
		guard let metadataFolder = try? outputFolder.createSubfolderIfNeeded(withName: "Metadata") else {
			stderr <<< "Couldn't create root folder to store metadata"
			return false
		}
		switch metadataFactory.generateMetadata(saveIn: metadataFolder, serial: index, metadataConfig: metadataConfig) {
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
}
