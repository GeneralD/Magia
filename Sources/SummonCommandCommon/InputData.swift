import AppKit
import Files

public struct InputData {
	public let assets: Assets
	public let serialText: SerialText?
	public let isSampleMode: Bool

	public init(assets: Assets, serialText: SerialText?, isSampleMode: Bool) {
		self.assets = assets
		self.serialText = serialText
		self.isSampleMode = isSampleMode
	}

	public enum Assets {
		case animated(layers: [ImageLayer<Folder>], duration: Double)
		case still(layers: [ImageLayer<File>])
	}

	public struct ImageLayer<F: Location> {
		public let imageLocation: F
		public let layer: String
		public let name: String
		public let probability: Double

		public init(imageLocation: F, layer: String, name: String, probability: Double) {
			self.imageLocation = imageLocation
			self.layer = layer
			self.name = name
			self.probability = probability
		}
	}

	public struct SerialText {
		public let formatText: NSAttributedString
		public let transform: CGAffineTransform

		public init(formatText: NSAttributedString, transform: CGAffineTransform) {
			self.formatText = formatText
			self.transform = transform
		}
	}
}
