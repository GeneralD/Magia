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
	func generateImage(saveIn folder: Folder, serial: Int, imageType: UTType) -> Result<File, ImageFactoryError> {
		guard imageType.isSupported else { return .failure(.unsupportedImageType) }

		let frames = generateAllFrameImages(queueIdentification: serial.description, serial: serial)
			.compactMap(\.cgImage)

		guard !frames.isEmpty else { return .failure(.noImage) }

		let fileURL = folder.url.appendingPathComponent(serial.description, conformingTo: imageType)
		guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, imageType.identifier as CFString, frames.count, nil) else {
			return .failure(.creatingFileFailed)
		}

		let properties = [imageType.dictionaryKey: [imageType.loopCountKey: 0]] as? CFDictionary // 0 to loop infinity
		CGImageDestinationSetProperties(destination, properties)

		let durationPerFrame = animationDuration / Double(frames.count)

		frames.forEach { frame in
			let properties = frames.count > 1
			// if multiple frames, it's going to be animated
			? [imageType.dictionaryKey: [imageType.delayTimeKey: durationPerFrame]] as? CFDictionary
			// no option to still image
			: nil
			CGImageDestinationAddImage(destination, frame, properties)
		}

		guard CGImageDestinationFinalize(destination) else {
			return .failure(.finalizeImageFailed)
		}

		guard let file = try? File(path: fileURL.path) else {
			return .failure(.creatingFileFailed)
		}

		return .success(file)
	}
}

private extension ImageFactory {
	func generateAllFrameImages(queueIdentification: String, serial: Int) -> [CIImage] {
		let frames = (0..<numberOfFrames).waitAll(queueLabelPrefix: queueIdentification) { frame -> CIImage? in
			var image = generateImage(for: frame)
			if let serialText = input.serialText {
				let text = serialText.formatText.format(serial)
				image = image?.draw(text: text, transform: serialText.transform)
			}
			if input.isSampleMode {
				image = image?.drawSample()
			}
			return image
		}
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
		switch input.assets {
		case let .animated(layers, _):
			return layers.map(\.imageLocation.files.array.count).max() ?? 0
		case .still:
			return 1
		}
	}

	func layerImages(frame: Int) -> [File] {
		switch input.assets {
		case let .animated(layers, _):
			return layers
				.map(\.imageLocation.files.array)
				.filter(\.isEmpty.not)
				.map { files in
					let sorted = files.sorted(at: \.name, by: <)
					return sorted[safe: frame] ?? sorted.last!
				}
		case let .still(layers):
			return layers.map(\.imageLocation)
		}
	}

	var animationDuration: Double {
		switch input.assets {
		case let .animated(_, duration):
			return duration
		case .still:
			return 0
		}
	}
}

enum ImageFactoryError: Error {
	case noImage
	case unsupportedImageType
	case creatingFileFailed
	case finalizeImageFailed
}

private extension UTType {
	var isSupported: Bool {
		self == .gif || self == .png
	}

	var dictionaryKey: String {
		switch self {
		case .gif:
			return kCGImagePropertyGIFDictionary as String
		case .png:
			return kCGImagePropertyPNGDictionary as String
		default:
			assertionFailure()
			return ""
		}
	}

	var loopCountKey: String {
		switch self {
		case .gif:
			return kCGImagePropertyGIFLoopCount as String
		case .png:
			return kCGImagePropertyAPNGLoopCount as String
		default:
			assertionFailure()
			return ""
		}
	}

	var delayTimeKey: String {
		switch self {
		case .gif:
			return kCGImagePropertyGIFDelayTime as String
		case .png:
			return kCGImagePropertyAPNGDelayTime as String
		default:
			assertionFailure()
			return ""
		}
	}
}
