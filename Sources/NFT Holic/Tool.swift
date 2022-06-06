import CollectionKit
import Files
import Foundation
import Regex
import SwiftCLI

class Tool: Command {
	var name = "nftholic"
	var shortDescription = "A NFT generator for NFT holic"

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

	@Flag("-p", "--png", description: "Make animated png instead of gif")
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

private extension Tool {
	func generate() throws -> [Bool] {
		// measure time
		let startDate = Date()
		defer { stdout <<< "Generating many images took \(Date().timeIntervalSince(startDate)) seconds." }

		let config = loadAssetConfig()
		let regexFactory = LayerStrictionRegexFactory(layerStrictions: config.combinations)
		let layerFolders = sort(subjects: inputFolder.subfolders, where: \.name, order: config.order?.selection)

		let results = indices.map { index -> Bool in
			// measure time
			let startDate = Date()
			defer { stdout <<< "Generating an image took \(Date().timeIntervalSince(startDate)) seconds." }

			let layers = layerFolders
				.reduce(into: [InputData.ImageLayer]()) { layers, folder in
					let limitRegex = regexFactory.validItemNameRegex(forLayer: folder.name, conditionLayers: layers)
					guard let selected = folder.subfolders.filter({ subfolder in
						guard let regex = limitRegex else { return true } // no limitation
						return subfolder.name =~ regex
					}).randomElement() else { return }
					layers.append(.init(framesFolder: selected, layer: folder.name, name: selected.name))
				}

			// arrange layers in the order of depth configured in json
			let sortedLayers = sort(subjects: layers, where: \.layer, order: config.order?.layerDepth)

			let serialText = InputData.SerialText(from: config.drawSerial)
			let input = InputData(layers: sortedLayers, animationDuration: animationDuration ?? 2, serialText: serialText, isSampleMode: isSampleMode)

			return generateImage(input: input, index: index) && generateMetadata(input: input, index: index, config: config.metadata)
		}

		return results
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
		guard let file = try? inputFolder.file(named: "config.json"),
			  let config = try? JSONDecoder().decode(AssetConfig.self, from: file.read()) else {
			stderr <<< "No valid config.json"
			stdout <<< "But still ok! We can continue processing..."
			return .empty
		}
		return config
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
			return subjects.first { subject in
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
