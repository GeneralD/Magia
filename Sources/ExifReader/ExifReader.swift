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
		let softwareName = exifData["Software"] as? String
		switch softwareName {
		case "NovelAI":
			guard let description = exifData["Description"] as? String else { return [] }
			return description
				.split(separator: ",")
				.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
				.map(spell)
		case "stability.ai":
			guard let description = exifData["Image Description"] as? String else { return [] }
			return description
				.split(separator: ",")
				.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
				.map(spell)
		default:
			return []
		}
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
private let cleanerRegex = #/^[\{\[\(]*(?<match>.+?)[\}\]\)]*$/#

private func spell(_ str: String) -> Spell {
	func reduce(_ base: Spell) -> Spell {
		// peel off braces
		if let match = try? inBracesRegex.wholeMatch(in: base.phrase)?.output.match.description {
			return reduce(.init(phrase: match, enhanced: base.enhanced + 1))
		}
		// peel off brackets
		if let match = try? inBracketsRegex.wholeMatch(in: base.phrase)?.output.match.description {
			return reduce(.init(phrase: match, enhanced: base.enhanced - 1))
		}
		// peel off parentheses
		if let match = try? inParenthesesRegex.wholeMatch(in: base.phrase)?.output.match.description {
			return reduce(.init(phrase: match, enhanced: base.enhanced + 1))
		}
		// clean parentheses of one half
		if let match = try? cleanerRegex.wholeMatch(in: base.phrase)?.output.match.description {
			return .init(phrase: match, enhanced: base.enhanced)
		}
		return base
	}
	return reduce(.init(phrase: str, enhanced: .zero))
}
