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

		init?(from config: AssetConfig.DrawSerial, inputFolder: Folder) {
			guard config.enabled, !config.format.isEmpty else { return nil }

			let font = loadFont(fontName: config.font, folder: inputFolder, size: config.size)
			let color = NSColor(hexString: config.color) ?? .black

			formatText = .init(string: config.format, attributes: [.font: font, .foregroundColor: color])
			transform = .init(translationX: config.offsetX, y: config.offsetY)
		}
	}
}

private func loadFont(fontName: String, folder: Folder, size: CGFloat) -> NSFont {
	let fontPath =
	(try? folder.file(named: fontName)) ??
	(try? folder.file(named: "\(fontName).ttf")) ??
	(try? folder.file(named: "\(fontName).otf"))

	let font = fontPath.flatMap { file in
		guard let url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, file.path as CFString, .cfurlposixPathStyle, false),
			  let provider = CGDataProvider(url: url),
			  let font = CGFont(provider) else { return nil }
		return CTFontCreateWithGraphicsFont(font, size, nil, nil)
	} as NSFont?

	return font ?? NSFont(name: fontName, size: size) ?? .systemFont(ofSize: size)
}

