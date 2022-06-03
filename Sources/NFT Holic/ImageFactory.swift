import CoreImage
import Files
import UniformTypeIdentifiers
import AppKit

struct ImageFactory {

	let input: InputData

	@discardableResult
	/// Generate an animated image.
	/// - Parameters:
	///   - folder: location to save generated image
	///   - fileName: file name without path and extension
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
				guard let serialText = input.serialText else {
					frames[frame] = generateImage(for: frame)
					return
				}
				let text = serialText.formatText.replaced(text: .init(format: serialText.formatText.string, serial))
				frames[frame] = generateImage(for: frame)?.draw(text: text)
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

extension NSAttributedString {
	func replaced(text: String) -> Self {
		.init(string: text, attributes: attributes(at: 0, effectiveRange: nil))
	}
}
