import CoreImage

extension CIImage {
	private static let ciContext = CIContext()

	var cgImage: CGImage? {
		type(of: self).ciContext.createCGImage(self, from: extent)
	}
}
