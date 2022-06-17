import CoreImage
import CoreImage.CIFilterBuiltins

private let ciContext = CIContext()

extension CIImage {
	var cgImage: CGImage? {
		ciContext.createCGImage(self, from: extent)
	}

	func draw(text: NSAttributedString, scaleFactor: Float = 1, transform: CGAffineTransform = .identity) -> CIImage {
		let filter = CIFilter.attributedTextImageGenerator()
		filter.text = text
		filter.scaleFactor = scaleFactor
		let textImage = filter.outputImage?.transformed(by: transform)
		return textImage?.composited(over: self) ?? self
	}
}
