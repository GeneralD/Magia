import AppKit
import CommandCommon
import Files
import SwiftCLI
import TokenFileNameFactory

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

	@Key("-s", "--start-index", description: "Auto incremented index start from what? (default is 1)", completion: .none, validation: [.greaterThanOrEqual(0)])
	var startIndex: Int!

	@Flag("--without-metadata", description: "Not to generate metadata")
	var noMetadata: Bool

	@Flag("--without-image", description: "Not to generate image")
	var noImage: Bool

	private lazy var nameFactory = TokenFileNameFactory(nameFormat: fileNameFormat, hash: hashFileName)

	public init(name: String) {
		self.name = name
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

		let assetFiles = inputFolder.files.recursive.filter { file in
			file.nameExcludingExtension != "config"
		}

		// TODO: code below
		return []
	}

	var indices: some Sequence<Int> {
		startIndex...
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
