import AppKit
import Files
import SwiftHEXColors

struct InputData {
	let layers: [ImageLayer]
	let animationDuration: Double
	let serialText: SerialText?
	let isSampleMode: Bool

	struct ImageLayer {
		let framesFolder: Folder
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
