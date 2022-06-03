import Files
import CoreImage

extension File {

	var ciImage: CIImage? {
		.init(contentsOf: .init(fileURLWithPath: path))
	}
}
