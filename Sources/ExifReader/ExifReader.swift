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
		if exifData["Software"] as? String == "NovelAI" {
			guard let description = exifData["Description"] as? String else { return [] }
			return description
				.split(separator: ",")
				.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
				.map(spell)
		}
		return []
	}
}

private extension ExifReader {
	var exif: [String : Any] {
		guard let image = CIImage(contentsOf: fileURL),
			  let exif = image.properties["{PNG}"] as? [String : Any] else { return [:] }
		return exif
	}
}

private let inBracesRegex = #/^\{(?<match>.+)\}$/#
private let inBracketsRegex = #/^\[(?<match>.+)\]$/#
private let inParenthesesRegex = #/^\((?<match>.+)\)$/#

private func spell(_ str: String) -> Spell {
	func reduce(_ base: Spell) -> Spell {
		if let match = try? inBracesRegex.wholeMatch(in: base.text)?.output.match.description {
			return reduce(.init(text: match, strength: base.strength * 1.05))
		}
		if let match = try? inBracketsRegex.wholeMatch(in: base.text)?.output.match.description {
			return reduce(.init(text: match, strength: base.strength / 1.05))
		}
		if let match = try? inParenthesesRegex.wholeMatch(in: base.text)?.output.match.description {
			return reduce(.init(text: match, strength: base.strength))
		}
		return base
	}
	return reduce(.init(text: str, strength: 1))
}
