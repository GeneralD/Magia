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

		init?(from drawSerial: AssetConfig.DrawSerial?) {
			guard let config = drawSerial,
				  config.enabled ?? true else {
				return nil
			}

			let fontName = config.font ?? ""
			let fontSize = config.size ?? 14
			let font = NSFont(name: fontName, size: fontSize) ?? .systemFont(ofSize: fontSize)

			let format = config.format ?? "%03d"
			let offsetX = config.offsetX ?? 0
			let offsetY = config.offsetY ?? 0
			let color = config.color.flatMap { NSColor(hexString: $0) } ?? .black

			formatText = .init(string: format, attributes: [.font: font, .foregroundColor: color])
			transform = .init(translationX: offsetX, y: offsetY)
		}
	}
}
