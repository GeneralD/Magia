import CoreImage

public struct ExifReader {
	let fileURL: URL

	public init(fileURL: URL) {
		self.fileURL = fileURL
	}
}

public extension ExifReader {
	var spells: [Spell] {
		let exifData = exif
		guard let softwareName = exifData[kCGImagePropertyPNGSoftware as String] as? String,
			  let description = exifData[kCGImagePropertyPNGDescription as String] as? String else { return [] }
		switch softwareName {
		case "NovelAI", "stability.ai":
			return description
				.split(separator: ",")
				.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
				.map(Spell.from)
		default:
			return []
		}
	}
}

private extension ExifReader {
	var exif: [String : Any] {
		guard let image = CIImage(contentsOf: fileURL),
			  let exif = image.properties[kCGImagePropertyPNGDictionary as String] as? [String : Any] else { return [:] }
		return exif
	}
}
