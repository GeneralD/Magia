import CoreImage
import Files

struct ImageFactory {

	let input: InputData

	@discardableResult
	func generateImage(saveIn folder: Folder, as fileName: String, isPng: Bool = false) -> Bool {
		let frames = (0..<input.numberOfFrames)
			.compactMap(generateImage(for:))
			.compactMap(\.cgImage)

		let saveUrl = NSURL(fileURLWithPath: "\(folder.path)/\(fileName)")
		guard let destimation = CGImageDestinationCreateWithURL(
			saveUrl,
			isPng ? kUTTypePNG : kUTTypeGIF,
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

	private func generateImage(for frame: Int) -> CIImage? {
		let imageFiles = input.layerImages(frame: frame)
		let compositedImage = imageFiles
			.compactMap(image(from:))
			.splat
			.map { head, tail in
				tail.reduce(head, { accum, image in
					// TODO: maybe this may be bad
					image.composited(over: accum)
				})
			}
		return compositedImage
	}

	private func image(from file: File) -> CIImage? {
		.init(contentsOf: .init(fileURLWithPath: file.path))
	}
}
