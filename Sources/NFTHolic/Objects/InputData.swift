import AppKit
import Files
import SwiftHEXColors

struct InputData {
	let assets: Assets
	let serialText: SerialText?
	let isSampleMode: Bool

	enum Assets {
		case animated(layers: [ImageLayer<Folder>], duration: Double)
		case still(layers: [ImageLayer<File>])
	}

	struct ImageLayer<F: Location> {
		let imageLocation: F
		let layer: String
		let name: String
		let probability: Double
	}

	struct SerialText {
		let formatText: NSAttributedString
		let transform: CGAffineTransform

		init?(from config: AssetConfig.DrawSerial) {
			guard config.enabled, !config.format.isEmpty else { return nil }

			let font = NSFont(name: config.font, size: config.size) ?? .systemFont(ofSize: config.size)
			let color = NSColor(hexString: config.color) ?? .black

			formatText = .init(string: config.format, attributes: [.font: font, .foregroundColor: color])
			transform = .init(translationX: config.offsetX, y: config.offsetY)
		}
	}
}
