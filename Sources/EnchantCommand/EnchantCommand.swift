import AppKit
import AssetConfig
import AssetConfigLoader
import CollectionKit
import CommandCommon
import ExifReader
import Files
import MetadataFactory
import SingleAssetElectionStore
import SingleAssetSequence
import SwiftCLI
import TokenFileNameFactory
import UniformTypeIdentifiers

public class EnchantCommand: Command {

	public let name: String
	public let shortDescription = "Make asset NFT"

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

	@Key("-q", "--quantity", description: "Number of creation", completion: .none, validation: [.greaterThan(0)])
	var creationCount: Int?

	@Key("-s", "--start-index", description: "Auto incremented index start from what? (default is 1)", completion: .none, validation: [.greaterThanOrEqual(0)])
	var startIndex: Int!

	@Key("-r", "--reprint", description: "Pickup assets based on data.sqlite file", completion: .filename)
	var sqliteFile: File?

	@Key("--baseurl", description: "Base URL to place metadata (default is difined in config.json)", completion: .none)
	var baseURL: URL?

	@Flag("-e", "--embedded", description: "Embed encoded image in metadata")
	var embedDecodedImageInMetadata: Bool

	@Flag("--without-metadata", description: "Not to generate metadata")
	var noMetadata: Bool

	@Flag("--without-image", description: "Not to generate image")
	var noImage: Bool

	private lazy var nameFactory = TokenFileNameFactory(nameFormat: fileNameFormat, hash: hashFileName)
	private lazy var metadataFactory = MetadataFactory(outputFolder: outputFolder, imageFolderName: imageFolderName)

	public init(name: String) {
		self.name = name
	}

	public var options: [OptionGroup] {
		[
			// embedDecodedImageInMetadata needs to make source image files, so noImage is unavailable.
			.atMostOne($noImage, $embedDecodedImageInMetadata),
		]
	}

	public func execute() throws {
		configureArguments()

		let results = try generate()
		logging(results: results)
	}
}

private extension EnchantCommand {

	// MARK: - Configure Default Values
	
	func configureArguments() {
		configureOutputFolder()
		configureImageFolderName()
		configureFileNameFormat()
		configureStartIndex()
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

	func configureStartIndex() {
		guard startIndex == nil else { return }
		$startIndex.update(to: 1)
	}

	// MARK: - Generate

	func generate() throws -> [Bool] {
		// measure time
		let startDate = Date()
		defer { stdout <<< "Generating items took \(Date().timeIntervalSince(startDate)) seconds." }

		let config = loadAssetConfig()
		let assetSequence = try assetSequence(election: config.singleAsset)
		let store = try SingleAssetElectionStore(inputDatabaseFile: sqliteFile, outputDatabaseFolder: outputFolder)
		defer { try? store.close() }

		return assetSequence
			.enumerated()
			.map { offset, file in
				let index = startIndex + offset
				return (index, store[index, inputFolder] ?? file)
			}
			.map { index, file in
				store[index, inputFolder] = file
				return generateImage(assetFile: file, index: index)
				&& generateMetadata(assetFile: file, index: index, config: config.metadata)
			}
	}

	@discardableResult
	func generateImage(assetFile: File, index: Int) -> Bool {
		guard !noImage else { return true }
		guard let imageFolder = try? outputFolder.createSubfolderIfNeeded(withName: imageFolderName) else {
			stderr <<< "Couldn't create root folder to store images"
			return false
		}

		guard let originalExtension = assetFile.extension,
			  let fileType = UTType(filenameExtension: originalExtension),
			  let preferredExtension = fileType.preferredFilenameExtension else { return false }

		let fileName = "\(nameFactory.fileName(from: index)).\(preferredExtension)"
		guard let _ = try? imageFolder.createFile(named: fileName, contents: assetFile.read()) else { return false }
		return true
	}

	@discardableResult
	func generateMetadata(assetFile: File, index: Int, config: any CommonMetadata & EnchantMetadata) -> Bool {
		guard !noMetadata else { return true }
		let imageData = embedDecodedImageInMetadata ? try? assetFile.read() : nil

		guard let fileExtension = assetFile.extension,
			  let fileType = UTType(filenameExtension: fileExtension) else { return false }

		let exifReader = ExifReader(fileURL: assetFile.url)
		let spells = exifReader.spells.map(\.phrase)

		switch metadataFactory.generateMetadata(
			from: .completedAsset(name: assetFile.nameExcludingExtension, spells: spells, config: config),
			as: nameFactory.fileName(from: index),
			serial: index,
			imageType: fileType,
			overrideBaseURL: baseURL,
			embeddedImage: imageData) {
			case let .success(file):
				stdout <<< "Created: \(file.path)"
				return true
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
					case .undifinedBaseURL:
						stderr <<< "BaseURL is not defined."
				}
				return false
		}
	}

	func assetSequence(election: EnchantSingleAssetElection) throws -> SingleAssetSequence {
		let assetFiles = inputFolder.files.recursive
			.filter { file in file.nameExcludingExtension != "config" }
		do {
			return try SingleAssetSequence(assetFiles: assetFiles, election: election, quantity: creationCount)
		} catch {
			switch error {
				case SingleAssetSequenceError.tooMuchQuantitySpecified:
					stderr <<< "Quantity must be less than or equal to number of assets if alphabetical or duplicatableShuffle is selected."
				case SingleAssetSequenceError.quantityMustBeSpecified:
					stderr <<< "Quantity must be specified if duplicatableShuffle is selected."
				default:
					stderr <<< error.localizedDescription
			}
			throw error
		}
	}

	// MARK: - Load Config File

	func loadAssetConfig() -> any EnchantAssetConfig {
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

	// MARK: - Logging

	func logging(results: some Sequence<Bool>) {
		let successCount = results.filter { $0 }.count
		stdout <<< "\(successCount) items have been generated!"

		let failureCount = results.filter(!).count
		guard failureCount > 0 else {
			stdout <<< "Finish gracefully!"
			return
		}
		stderr <<< "Failed to generate \(failureCount) items..."
	}
}
