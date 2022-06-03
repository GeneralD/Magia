import CoreImage

private let ciContext = CIContext()

extension CIImage {
	var cgImage: CGImage? {
		ciContext.createCGImage(self, from: extent)
	}
}
