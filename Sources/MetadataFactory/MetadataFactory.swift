import AssetConfig
import CollectionKit
import Files
import Foundation
import RegexBuilder
import UniformTypeIdentifiers

public struct MetadataFactory {
	let outputFolder: Folder
	let imageFolderName: String

	public init(outputFolder: Folder, imageFolderName: String) {
		self.outputFolder = outputFolder
		self.imageFolderName = imageFolderName
	}
}

public extension MetadataFactory {
	@discardableResult
	func generateMetadata(from subject: MetadataSubject, as name: String, serial: Int, imageType: UTType, overrideBaseURL: URL? = nil, embededImage: Data? = nil) -> Result<File, MetadataFactoryError> {
		guard let jsonFile = try? outputFolder.createFileIfNeeded(withName: "\(name).json") else { return .failure(.creatingFileFailed) }

		let attributes = attributes(subject: subject)
			.unique(where: \.identity) { lhs, rhs in
				// if 2 or more rankedNumbers with same traitType, integrate the value by +
				guard case let (.rankedNumber(_, lhsValue), .rankedNumber(rhsType, rhsValue)) = (lhs, rhs) else { return rhs }
				return .rankedNumber(traitType: rhsType, value: lhsValue + rhsValue)
			}

		let config = subject.config
		guard let baseURL = overrideBaseURL ?? config.baseUrl else {
			try? jsonFile.delete()
			return .failure(.undifinedBaseURL)
		}

		// sort attributes
		guard let sortedAttribute = sort(attributes: attributes, traitOrder: config.traitOrder) else {
			try? jsonFile.delete()
			return .failure(.invalidMetadataSortConfig)
		}

		let imageURLType = embededImage.map(ImageURLType.dataURL(data: )) ?? .locationURL(baseURL: baseURL, name: name)
		let imageURL = imageURL(urlType: imageURLType, imageType: imageType)

		let name = replace(in: config.nameFormat, attributes: attributes, serial: serial)
		let description = replace(in: config.descriptionFormat, attributes: attributes, serial: serial)

		let externalURL = config.externalUrlFormat.map { replace(in: $0, attributes: attributes, serial: serial) }.flatMap(URL.init(string: ))

		guard let backgroundColor = config.backgroundColor.wholeMatch(of: hexColorRegex)?[hexColorRef].description else {
			try? jsonFile.delete()
			return .failure(.invalidBackgroundColorCode)
		}

		let metadata = Metadata(imageURL: imageURL, externalURL: externalURL, description: description, name: name, attributes: sortedAttribute, backgroundColor: backgroundColor)

		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted

		guard let _ = try? jsonFile.write(encoder.encode(metadata)) else {
			try? jsonFile.delete()
			return .failure(.writingFileFailed)
		}
		return .success(jsonFile)
	}
}

private extension MetadataFactory {
	func imageURL(urlType: ImageURLType, imageType: UTType) -> URL {
		switch urlType {
			case let .locationURL(baseURL, name):
				return baseURL
					.appendingPathComponent(imageFolderName)
					.appendingPathComponent(name, conformingTo: imageType)
			case let .dataURL(data):
				return URL(string: "data:image/\(imageType.preferredFilenameExtension ?? "");base64,\(data.base64EncodedString())") ?? .init(fileURLWithPath: "")
		}
	}

	func attributes(subject: MetadataSubject) -> [Metadata.Attribute] {
		switch subject {
		case let .generativeAssets(layers, config):
			return attributes(layers: layers, config: config)
		case let .completedAsset(name, spells, config):
			// merge attributes come from asset's name and AI spells
			return attributes(assetName: name, config: config) + attributes(spells: spells, config: config)
		}
	}

	func attributes(layers: some Sequence<MetadataSubject.LayerSubject>, config: some CommonMetadata) -> [Metadata.Attribute] {
		return layers.reduce([Metadata.Attribute]()) { accum, layer in
			accum + config.traitData
				.filter { trait in
					trait.conditions.contains { condition in
						layer.layer.contains(condition.layer) && layer.name.contains(condition.name)
					}
				}
				.flatMap(\.traits)
				.compactMap { $0.metadata(probability: layer.probability) }
		}
	}

	func attributes(assetName: String, config: some CommonMetadata) -> [Metadata.Attribute] {
		config.traitData
			.filter { trait in
				trait.conditions.contains { condition in
					assetName.contains(condition.name)
				}
			}
			.flatMap(\.traits)
			.compactMap(\.metadata)
	}

	func attributes(spells: some Sequence<String>, config: some EnchantMetadata) -> [Metadata.Attribute] {
		let filteredSpells = spells.filter { spell in
			let isAllowlist = config.aiTraitListing.intent == .allowlist
			let isSpellListed = config.aiTraitListing.list.contains { regex in
				spell.contains(regex)
			}
			return isAllowlist == isSpellListed
		}

		let traits = filteredSpells
			.flatMap { spell -> [CommonTrait] in
				let matched = config.aiTraitData.filter { data in spell.contains(data.spell) }
				guard !matched.isEmpty else {
					return [.simple(value: spell.capitalized)]
				}
				return matched.flatMap(\.traits)
			}
		return traits.compactMap(\.metadata)
	}

	/// Replace trait placeholder with value of the trait.
	///
	/// e.g. "${First Name} %03d" will be like "James 007"
	/// - Parameters:
	///   - format: text includes placeholders
	///   - attributes: traits
	///   - serial: serial number
	/// - Returns: result
	func replace(in format: String, attributes: [Metadata.Attribute], serial: Int) -> String {
		let text = format.replacing(integerFormatRegex) { match in
			String(format: match.output.description, serial)
		}

		let attrRegex = #/\$\{(?<attr>.*)\}/#
		return text.replacing(attrRegex) { match in
			let trait = match.attr.description
			return attributes.lazy.compactMap { attr in
				switch attr {
				case .textLabel(traitType: trait, value: let value):
					return value
				case .numberLabel(traitType: trait, value: let value):
					return value.description
				case .boostNumber(traitType: trait, value: let value, maxValue: _):
					return value.description
				case .boostPercentage(traitType: trait, value: let value):
					return value.description
				case .rankedNumber(traitType: trait, value: let value):
					return value.description
				case _:
					return nil
				}
			}.first ?? ""
		}
	}

	func sort(attributes: [Metadata.Attribute], traitOrder: [String]) -> [Metadata.Attribute]? {
		guard !traitOrder.isEmpty else { return attributes.sorted(at: { $0.traitType ?? "" }, by: <) } // just sort alphabetically
		guard let sorted = attributes.sort(where: \.identity, orderSample: traitOrder, shouldCover: true) else { return nil } // fail
		return sorted // ok
	}
}

private enum ImageURLType {
	case locationURL(baseURL: URL, name: String)
	case dataURL(data: Data)
}

private let hexColorRef = Reference(Substring.self)

private let hexColorRegex = Regex {
	Optionally("#")
	Capture(as: hexColorRef) {
		ChoiceOf {
			Repeat(.hexDigit, count: 3)
			Repeat(.hexDigit, count: 6)
		}
	}
}

private let integerFormatRegex = Regex {
	"%"
	ZeroOrMore(.digit)
	"d"
}

private extension CommonTrait {
	var metadata: Metadata.Attribute? {
		metadata()
	}

	func metadata(probability: Double? = nil) -> Metadata.Attribute? {
		switch self {
		case let .simple(value):
			return .simple(value: value)
		case let .label(trait, .string(value)):
			return .textLabel(traitType: trait, value: value)
		case let .label(trait, value: .date(value)):
			return .dateLabel(traitType: trait, value: value)
		case let .label(trait, value: .number(value)):
			return .numberLabel(traitType: trait, value: value)
		case let .rankedNumber(trait, value):
			return .rankedNumber(traitType: trait, value: value)
		case let .boostNumber(trait, value, max):
			return .boostNumber(traitType: trait, value: value, maxValue: max)
		case let .boostPercentage(trait, value):
			return .boostPercentage(traitType: trait, value: value)
		case let .rarityPercentage(trait):
			guard let probability else { return nil }
			return  .boostPercentage(traitType: trait, value: .init(probability * 100, digitsAfterPoint: 2))
		}
	}
}
