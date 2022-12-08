import AppKit
import AssetConfig
import Files
import GenCommandCommon
import SwiftHEXColors

extension InputData.SerialText {
	public init?(from config: some DrawSerial, inputFolder: Folder) {
		guard config.enabled, !config.format.isEmpty else { return nil }

		let font = loadFont(fontName: config.font, folder: inputFolder, size: config.size)
		let color = NSColor(hexString: config.color) ?? .black

		self = .init(
			formatText: .init(string: config.format, attributes: [.font: font, .foregroundColor: color]),
			transform: .init(translationX: config.offsetX, y: config.offsetY))
	}
}

private func loadFont(fontName: String, folder: Folder, size: CGFloat) -> NSFont {
	// try to find in input folder
	let fontFile = ["", ".ttf", ".otf"].reduce(nil) { file, suffix in
		file ?? (try? folder.file(named: fontName + suffix))
	}
	let font = fontFile.flatMap { file in
		guard let url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, file.path as CFString, .cfurlposixPathStyle, false),
			  let provider = CGDataProvider(url: url),
			  let font = CGFont(provider) else { return nil }
		return CTFontCreateWithGraphicsFont(font, size, nil, nil)
	} as NSFont?

	// or load from system
	return font ?? NSFont(name: fontName, size: size) ?? .systemFont(ofSize: size)
}
