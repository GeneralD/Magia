import CollectionKit
import CoreImage
import Files
import UniformTypeIdentifiers
import AppKit

struct ImageFactory {

	let input: InputData

	/// Generate an animated image.
	/// - Parameters:
	///   - folder: location to save generated image
	///   - serial: will be file name (without path and extension)
	///   - isPng: to create animated png instead of gif
	/// - Returns: if success
	@discardableResult
	func generateImage(saveIn folder: Folder, serial: Int, isPng: Bool = false) -> Result<File, ImageFactoryError> {
		let frames = generateAllFrameImages(queueIdentification: serial.description, serial: serial)
			.compactMap(\.cgImage)

		let utType: UTType = isPng ? .png : .gif
		guard let file = try? folder.createFile(named: "\(serial).\(isPng ? "png" : "gif")"),
			  let destination = CGImageDestinationCreateWithURL(file.url as CFURL, utType.identifier as CFString, frames.count, nil) else {
			return .failure(.creatingFileFailed)
		}

		let dictionaryKey = (isPng ? kCGImagePropertyPNGDictionary : kCGImagePropertyGIFDictionary) as String
		let loopCountKey = (isPng ? kCGImagePropertyAPNGLoopCount : kCGImagePropertyGIFLoopCount) as String
		let delayTimeKey = (isPng ? kCGImagePropertyAPNGDelayTime : kCGImagePropertyGIFDelayTime) as String

		let properties = [dictionaryKey: [loopCountKey: 0]] as? CFDictionary // 0 to loop infinity
		CGImageDestinationSetProperties(destination, properties)

		let durationPerFrame = input.animationDuration / Double(frames.count)

		frames.forEach { frame in
			let properties = [dictionaryKey: [delayTimeKey: durationPerFrame]] as? CFDictionary
			CGImageDestinationAddImage(destination, frame, properties)
		}

		guard CGImageDestinationFinalize(destination) else {
			try? file.delete()
			return .failure(.finalizeImageFailed)
		}

		return .success(file)
	}
}

private extension ImageFactory {
	func generateAllFrameImages(queueIdentification: String, serial: Int) -> [CIImage] {
		@Locked var frames = [Int: CIImage?]()
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

enum ImageFactoryError: Error {
	case creatingFileFailed
	case finalizeImageFailed
}
