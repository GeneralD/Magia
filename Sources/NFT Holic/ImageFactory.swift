import CoreImage
import Files

struct ImageFactory {

	let input: InputData

	@discardableResult
	/// Generate an animated image.
	/// - Parameters:
	///   - folder: location to save generated image
	///   - fileName: file name without path and extension
	///   - isPng: to create animated png instead of gif
	/// - Returns: if success
	func generateImage(saveIn folder: Folder, as fileName: String, isPng: Bool = false) -> Bool {
		let frames = generateAllFrameImages(queueIdentification: fileName)
			.compactMap(\.cgImage)

		let saveUrl = NSURL(fileURLWithPath: "\(folder.path)/\(fileName).\(isPng ? "png" : "gif")")
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
}

private extension ImageFactory {
	func generateAllFrameImages(queueIdentification: String) -> [CIImage] {
		@Atomic var frames = [Int: CIImage?]()
		let group = DispatchGroup()
		for frame in 0..<numberOfFrames {
			group.enter()
			let dispatch = DispatchQueue(label: "\(queueIdentification).\(frame)", qos: .utility, attributes: .concurrent)
			dispatch.async(group: group) {
				frames[frame] = generateImage(for: frame)
				group.leave()
			}
		}
		group.wait()
		return frames.sorted(at: \.key, by: <).compactMap(\.value)
	}

	func generateImage(for frame: Int) -> CIImage? {
		let imageFiles = layerImages(frame: frame)
		let compositedImage = imageFiles
			.compactMap(\.ciImage)
			.splat
			.map { head, tail in
				tail.reduce(head) { accum, image in
					image.composited(over: accum)
				}
			}
		return compositedImage
	}

	var numberOfFrames: Int {
		input.layers.map(\.framesFolder.files.array.count).max() ?? 0
	}

	func layerImages(frame: Int) -> [File] {
		input.layers
			.map(\.framesFolder)
			.filter { !$0.isEmpty(includingHidden: false) }
			.map { layerFolder in
				let sorted = layerFolder.files.array.sorted(at: \.name, by: <)
				return sorted[safe: frame] ?? sorted.last!
			}
	}
}
