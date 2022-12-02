import AppKit
import CoreImage
import Foundation

extension CIImage {
	/// All images should be same size so we can cache waterdrop once created!
	private static var cachedTextImage: CIImage?

	func drawSample(text: NSMutableAttributedString = .init(string: "SAMPLE\nSAMPLE\nSAMPLE", attributes: [.foregroundColor: NSColor.white, .font: NSFont.systemFont(ofSize: 400)])) -> CIImage {
		guard let textImage = type(of: self).cachedTextImage else {
			let filter = CIFilter.attributedTextImageGenerator()
			filter.text = text
			filter.scaleFactor = 1
			guard let textImage = filter.outputImage else { return self }

			// scale to fit to image
			let scaleX = extent.size.width / textImage.extent.size.width
			let scaleY = extent.size.height / textImage.extent.size.height
			let scale = min(scaleX, scaleY)
			let textImageScaled = textImage.transformed(by: .init(scaleX: scale, y: scale))

			// translation to center
			let translationX = (extent.size.width - textImageScaled.extent.size.width) / 2
			let translationY = (extent.size.height - textImageScaled.extent.size.height) / 2
			type(of: self).cachedTextImage = textImageScaled.transformed(by: .init(translationX: translationX, y: translationY))
			return drawSample(text: text)
		}
		return textImage.composited(over: self)
	}
}
