import CollectionKit
import CoreImage
import Files
import Regex
import UniformTypeIdentifiers
import AppKit

struct ImageFactory {

	let input: InputData

	@discardableResult
	/// Generate an animated image.
	/// - Parameters:
	///   - folder: location to save generated image
	///   - serial: will be file name (without path and extension)
	///   - isPng: to create animated png instead of gif
	/// - Returns: if success
	func generateImage(saveIn folder: Folder, serial: Int, isPng: Bool = false) -> Bool {
		let frames = generateAllFrameImages(queueIdentification: serial.description, serial: serial)
			.compactMap(\.cgImage)

		let saveUrl = NSURL(fileURLWithPath: "\(folder.path)/\(serial).\(isPng ? "png" : "gif")")
		guard let destimation = CGImageDestinationCreateWithURL(
			saveUrl,
			(isPng ? UTType.png : UTType.gif).identifier as CFString,
			frames.count,
			nil) else { return false }

		let dictionaryKey = (isPng ? kCGImagePropertyPNGDictionary : kCGImagePropertyGIFDictionary) as String
		let loopCountKey = (isPng ? kCGImagePropertyAPNGLoopCount : kCGImagePropertyGIFLoopCount) as String
		let delayTimeKey = (isPng ? kCGImagePropertyAPNGDelayTime : kCGImagePropertyGIFDelayTime) as String

		let properties = [dictionaryKey: [loopCountKey: 0]] as? CFDictionary // 0 to loop infinity
		CGImageDestinationSetProperties(destimation, properties)

		let durationPerFrame = input.animationDuration / Double(frames.count)

		frames.forEach { frame in
			let properties = [dictionaryKey: [delayTimeKey: durationPerFrame]] as? CFDictionary
			CGImageDestinationAddImage(destimation, frame, properties)
		}

		guard CGImageDestinationFinalize(destimation) else { return false }

		return true
	}

	/// Generate a metadata json.
	/// - Parameters:
	///   - folder: location to save generated metadata
	///   - serial: will be file name (without path and extension)
	/// - Returns: if success
	func generateMetadata(saveIn folder: Folder, serial: Int, metadataConfig config: AssetConfig.Metadata) -> Bool {
		guard let jsonFile = try? folder.createFileIfNeeded(withName: "\(serial).json") else { return false }

		let attributes = input.layers.reduce([Metadata.Attribute]()) { accum, layer in
			return accum +
			(config.textLabels ?? [])
				.filtered(by: layer)
				.map { label in	Metadata.Attribute.textLabel(traitType: label.trait, value: label.value) }
		}.unique(where: \.identity)

		// image url is required field
		guard let imageURL = URL(string: .init(format: config.imageUrlFormat, serial)) else {
			try? jsonFile.delete()
			return false
		}

		// TODO: override defaults values
		let name = String(format: config.defaultNameFormat, serial)
		let description = String(format: config.defaultDescriptionFormat, serial)

		let externalURL = config.externalUrlFormat.map { String(format: $0, serial) }.flatMap(URL.init(string: ))
		let backgroundColor = config.backgroundColor ?? "ffffff"

		let metadata = Metadata(image: imageURL, externalURL: externalURL, description: description, name: name, attributes: attributes, backgroundColor: backgroundColor)

		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted

		guard let _ = try? jsonFile.write(encoder.encode(metadata)) else {
			try? jsonFile.delete()
			return false
		}
		return true
	}
}

private extension ImageFactory {
	func generateAllFrameImages(queueIdentification: String, serial: Int) -> [CIImage] {
		@Atomic var frames = [Int: CIImage?]()
		let group = DispatchGroup()
		for frame in 0..<numberOfFrames {
			group.enter()
			let dispatch = DispatchQueue(label: "\(queueIdentification).\(frame)", qos: .utility, attributes: .concurrent)
			dispatch.async(group: group) {
				defer { group.leave() }
				var image = generateImage(for: frame)
				if let serialText = input.serialText {
					let text = serialText.formatText.format(serial)
					image = image?.draw(text: text, transform: serialText.transform)
				}
				if input.isSampleMode {
					image = image?.drawSample()
				}
				frames[frame] = image
			}
		}
		group.wait()
		return frames.sorted(at: \.key, by: <).compactMap(\.value)
	}

	func generateImage(for frame: Int) -> CIImage? {
		layerImages(frame: frame)
			.compactMap(\.ciImage)
			.splat
			.map { head, tail in
				tail.reduce(head) { accum, image in
					image.composited(over: accum)
				}
			}
	}

	var numberOfFrames: Int {
		input.layers.map(\.framesFolder.files.array.count).max() ?? 0
	}

	func layerImages(frame: Int) -> [File] {
		input.layers
			.map(\.framesFolder.files.array)
			.filter(\.isEmpty.not)
			.map { files in
				let sorted = files.sorted(at: \.name, by: <)
				return sorted[safe: frame] ?? sorted.last!
			}
	}
}
