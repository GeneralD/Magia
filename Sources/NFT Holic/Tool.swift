import CollectionKit
import Files
import Foundation
import SwiftCLI
import AppKit

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

	// TODO: use and implement
	@Flag("-x", "--sample", description: "Generate image with watermark (Not for sales)")
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
		defer { stdout <<< "Generating many images take \(Date().timeIntervalSince(startDate)) seconds." }

		let results = indices.map { index -> Bool in
			// measure time
			let startDate = Date()
			defer { stdout <<< "Generating an image takes \(Date().timeIntervalSince(startDate)) seconds." }

			let layers = inputFolder.subfolders.array
			// sort alphabetically and bigger comes fronter layer
				.sorted(at: \.name, by: <)
				.reduce(into: [InputData.ImageLayer]()) { accum, folder in
					guard let selected = folder.subfolders.array.randomElement() else { return }
					accum.append(.init(framesFolder: selected, layer: folder.name, name: selected.name))
				}

			let input = InputData(layers: layers, animationDuration: animationDuration ?? 2, serialText: serialText)
			let factory = ImageFactory(input: input)

			guard factory.generateImage(saveIn: outputFolder, serial: index, isPng: isPng) else {
				stdout <<< "Generating image was failed..."
				return false
			}
			return true
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

	var serialText: InputData.SerialText? {
		// TODO: read from JSON
		guard let font = NSFont(name: "M+ 1p black", size: 48) else { return nil }
		return .init(
			formatText: .init(string: "#%05d", attributes: [.font: font, .foregroundColor: NSColor.black]),
			transform: .init(translationX: 40, y: 10))
	}
}
