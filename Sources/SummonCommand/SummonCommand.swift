import AssetConfig
import AssetConfigLoader
import CommandCommon
import SummonCommandCommon
import ImageFactory
import LayerConstraint
import MetadataFactory
import RandomizationController
import RecipeStore
import TokenFileNameFactory
import AppKit
import CollectionKit
import Files
import Foundation
import SwiftCLI
import SwiftHEXColors
import UniformTypeIdentifiers

public class SummonCommand: Command {

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

	@Flag("-e", "--embedded", description: "Embed encoded image in metadata")
	var embedDecodedImageInMetadata: Bool

	@Flag("-f", "--overwrite", description: "Overwrite existing files")
	var forceOverwrite: Bool

	@Flag("--without-metadata", description: "Not to generate metadata")
	var noMetadata: Bool

	@Flag("--without-image", description: "Not to generate image")
	var noImage: Bool

	@Flag("--sample", description: "Generate image with watermark (Not for sales)")
	var isSampleMode: Bool

	// MARK: - Command Implementations
	
	public let name: String
	public let shortDescription = "Generate many NFTs"

	private lazy var nameFactory = TokenFileNameFactory(nameFormat: fileNameFormat, hash: hashFileName)
	private lazy var metadataFactory = MetadataFactory(outputFolder: outputFolder, imageFolderName: imageFolderName)

	public init(name: String) {
		self.name = name
	}

	public var optionGroups: [OptionGroup] {
		[
			// if both noMetadata and noImage are true, nothing happens.
			// embedDecodedImageInMetadata needs to make source image files, so noImage is unavailable.
			.atMostOne($noMetadata, $noImage, $embedDecodedImageInMetadata),
		]
	}

	public func execute() throws {
		configureArguments()

		let results = try generate()
		logging(results: results)
	}
}

private extension SummonCommand {

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
		let serialText = serialText(from: config.drawSerial)
		let constraintFactory = LayerConstraintFactory(layerStrictions: config.combinations, specials: config.specials)
		let randomManager = RandomizationController(config: config.randomization)
		let layerFolders = sort(subjects: inputFolder.subfolders, where: \.nameExcludingExtension, order: config.order.selection)

		func inputData<F: Location, S: Sequence>(forIndex index: Int, locations: (Folder) -> S, reservedAllocationManager: ReservedAllocationManager) -> (InputData, ReservedAllocationManager) where F: Hashable, S.Element == F {
			let (layers, allocationManager) = layerFolders
				.reduce(into: [InputData.ImageLayer<F>](), reservedAllocationManager) { layers, reservation, layerFolder in
					let targetLayer = layerFolder.name
					let constraint = constraintFactory.constraint(forIndex: index, forLayer: targetLayer, conditionLayers: layers.map(\.layerConstraintSubject))
					let validCandidates = locations(layerFolder).filter { f in
						constraint.isValidItem(name: f.nameExcludingExtension)
					}
					let candidates = reservation.dealNext(originalCandidates: validCandidates, targetLayer: targetLayer)
					guard let elected = randomManager.elect(from: candidates, targetLayer: targetLayer) else { return }
					layers.append(.init(imageLocation: elected.element, layer: targetLayer, name: elected.element.nameExcludingExtension, probability: elected.probability))
				}

			// arrange layers in the order of depth configured in json
			let sortedLayers = sort(subjects: layers, where: \.layer, order: config.order.layerDepth)

			let assets: InputData.Assets
			switch sortedLayers {
				case let (folders as [InputData.ImageLayer<Folder>]) as Any:
					assets = .animated(layers: folders, duration: animationDuration)
				case let (files as [InputData.ImageLayer<File>]) as Any:
					assets = .still(layers: files)
				default:
					exit(1)
			}
			return (InputData(assets: assets, serialText: serialText, isSampleMode: isSampleMode), allocationManager)
		}

		let recipeStore = try RecipeStore(inputDatabaseFile: sqliteFile, outputDatabaseFolder: outputFolder)
		defer { try? recipeStore.close() }

		let animated = isAnimatedAsset
		let reservedAllocationManager = ReservedAllocationManager(config: config.randomization.allocations)

		let (results, _) = try indices
			.reduce(into: [Bool](), reservedAllocationManager) { results, reservation, index in
				// measure time
				let startDate = Date()
				defer { stdout <<< "Generating an image took \(Date().timeIntervalSince(startDate)) seconds." }

				let storedAssets = try recipeStore.storedAssets(for: index, isAnimated: animated, animationDuration: animationDuration, inputFolder: inputFolder)
				let reprintData = storedAssets.map { InputData(assets: $0, serialText: serialText, isSampleMode: isSampleMode) }

				let input: InputData
				(input, reservation) = {
					// use reprint data?
					guard let reprintData else {
						// or create new
						return animated
						? inputData(forIndex: index, locations: \.subfolders, reservedAllocationManager: reservation)
						: inputData(forIndex: index, locations: \.files, reservedAllocationManager: reservation)
					}
					return (reprintData, reservation)
				} ()

				try recipeStore.storeAssets(for: index, source: input, inputFolder: inputFolder)

				// apply some arguments
				func generateMetadata(embededImage data: Data?) -> Bool {
					switch self.generateMetadata(input: input, index: index, config: config.metadata, embededImage: data) {
						case .nothing, .success:
							return true
						case .failure:
							return false
					}
				}

				// generate image and metadata
				switch generateImage(input: input, index: index) {
					case .nothing:
						results.append(generateMetadata(embededImage: nil))
					case let .success(file):
						results.append(generateMetadata(embededImage: try? file.read()))
					case .failure:
						results.append(false)
				}
			}

		return results
	}

	enum GenResult {
		case nothing
		case success(file: File)
		case failure
	}

	@discardableResult
	func generateImage(input: InputData, index: Int) -> GenResult {
		guard !noImage else { return .nothing }
		guard let imageFolder = try? outputFolder.createSubfolderIfNeeded(withName: imageFolderName) else {
			stderr <<< "Couldn't create root folder to store images"
			return .failure
		}
		let imageFactory = ImageFactory(input: input)
		switch imageFactory.generateImage(saveIn: imageFolder, as: nameFactory.fileName(from: index), serial: index, imageType: imageType) {
			case let .success(file):
				stdout <<< "Created: \(file.path)"
				return .success(file: file)
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
				return .failure
		}
	}

	@discardableResult
	func generateMetadata(input: InputData, index: Int, config: any CommonMetadata, embededImage data: Data? = nil) -> GenResult {
		guard !noMetadata else { return .nothing }
		let imageData = embedDecodedImageInMetadata ? data : nil

		switch metadataFactory.generateMetadata(from: input.assets.metadataSubject(config: config), as: nameFactory.fileName(from: index), serial: index, imageType: imageType, embededImage: imageData) {
			case let .success(file):
				stdout <<< "Created: \(file.path)"
				return .success(file: file)
			case let .failure(error):
				switch error {
					case .creatingFileFailed:
						stderr <<< "Couldn't create file to write metadata."
					case .invalidMetadataSortConfig:
						stderr <<< "Sorting metadata config should cover all trait you defined."
					case .invalidBackgroundColorCode:
						stderr <<< "backgroundColor in metadata should be 3 or 6 hex code without # prefix."
					case .writingFileFailed:
						stderr <<< "Writing metadata failed."
				}
				return .failure
		}
	}

	// MARK: - Load Config File

	func loadAssetConfig() -> any SummonAssetConfig {
		let loader = AssetConfigLoader()
		
		guard let file = inputFolder.files.first(where: { $0.nameExcludingExtension == "config" }) else {
			stderr <<< "Config file not found in \(inputFolder.name)"
			stdout <<< "But still ok! We can continue processing..."
			return loader.defaultConfig
		}

		switch loader.load(from: file) {
			case .success(let config):
				return config
			case .failure(.incompatibleFileExtension):
				stderr <<< "Incompatible file extension: \(file.name)"
				stdout <<< "But still ok! We can continue processing..."
				return loader.defaultConfig
			case .failure(.invalidConfigFile):
				stderr <<< "No valid config file!"
				stdout <<< "But still ok! We can continue processing..."
				return loader.defaultConfig
		}
	}

	// MARK: - SerialText from config

	func serialText(from config: some SummonDrawSerial) -> InputData.SerialText? {
		guard config.enabled, !config.format.isEmpty else { return nil }

		let font = loadFont(fontName: config.font, folder: inputFolder, size: config.size)
		let color = NSColor(hexString: config.color) ?? .black

		return .init(
			formatText: .init(string: config.format, attributes: [.font: font, .foregroundColor: color]),
			transform: .init(translationX: config.offsetX, y: config.offsetY))
	}

	func loadFont(fontName: String, folder: Folder, size: CGFloat) -> NSFont {
		// try to find in input folder
		let fontFile = ["", ".ttf", ".otf"].reduce(nil) { file, suffix in
			file ?? (try? folder.file(named: fontName + suffix))
		}
		let font = fontFile.flatMap { file in
			guard let url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, file.path as CFString, .cfurlposixPathStyle, false),
				  let provider = CGDataProvider(url: url),
				  let font = CGFont(provider) else { return nil }
			return CTFontCreateWithGraphicsFont(font, size, nil, nil)
		} as NSFont?

		// or load from system
		return font ?? NSFont(name: fontName, size: size) ?? .systemFont(ofSize: size)
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

	/// Indices of images to create.
	var indices: [Int] {
		let skips = forceOverwrite
		? []
		: outputFolder.files.map(\.nameExcludingExtension)

		return (startIndex..<(startIndex + creationCount))
			.map { index in (index, nameFactory.fileName(from: index)) }
			.unless { _, fileName in skips.contains(fileName) }
			.map(\.0)
	}

	func sort<Subjects: Sequence>(subjects: Subjects, where: (Subjects.Element) -> String, order: (some Sequence<String>)?) -> [Subjects.Element] {
		let array = subjects.array
		let sortedAlphabetically = array.sorted(at: `where`, by: <)
		guard let order else { return sortedAlphabetically }
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

	func logging(results: some Sequence<Bool>) {
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
