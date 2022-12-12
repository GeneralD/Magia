import CollectionKit
import Files
import Foundation
import RegexBuilder
import UniformTypeIdentifiers
import protocol AssetConfig.Metadata

public struct MetadataFactory {
	public init() {}
}

public extension MetadataFactory {
	@discardableResult
	func generateMetadata(from layers: some Sequence<MetadataLayerSubject>, saveIn folder: Folder, as name: String, serial: Int, metadataConfig config: some AssetConfig.Metadata, imageFolderName: String, imageType: UTType) -> Result<File, MetadataFactoryError> {
		guard let jsonFile = try? folder.createFileIfNeeded(withName: "\(name).json") else { return .failure(.creatingFileFailed) }
		let attributes = layers.reduce([Metadata.Attribute]()) { accum, layer in
			accum + config.data
				.filter { trait in
					trait.conditions.contains { condition in
						condition.layer == layer.layer && layer.name.contains(condition.name)
					}
				}
				.flatMap(\.traits)
				.map { trait in
					switch trait {
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
						return  .boostPercentage(traitType: trait, value: .init(layer.probability * 100, digitsAfterPoint: 2))
					}
				}
		}.unique(where: \.identity) { attr0, attr1 in
			// if 2 or more rankedNumbers with same traitType, integrate the value by +
			guard case let (.rankedNumber(_, value0), .rankedNumber(type1, value1)) = (attr0, attr1) else { return attr1 }
			return .rankedNumber(traitType: type1, value: value0 + value1)
		}

		// sort attributes
		guard let sortedAttribute = sort(attributes: attributes, traitOrder: config.traitOrder) else {
			try? jsonFile.delete()
			return .failure(.invalidMetadataSortConfig)
		}

		let imageURL = config.baseUrl
			.appendingPathComponent(imageFolderName)
			.appendingPathComponent(name, conformingTo: imageType)

		let name = replace(in: config.nameFormat, attributes: attributes, serial: serial)
		let description = replace(in: config.descriptionFormat, attributes: attributes, serial: serial)

		let externalURL = config.externalUrlFormat.map { replace(in: $0, attributes: attributes, serial: serial) }.flatMap(URL.init(string: ))

		guard let backgroundColor = config.backgroundColor.wholeMatch(of: hexColorRegex)?[hexColorRef].description else {
			try? jsonFile.delete()
			return .failure(.invalidBackgroundColorCode)
		}

		let metadata = Metadata(image: imageURL, externalURL: externalURL, description: description, name: name, attributes: sortedAttribute, backgroundColor: backgroundColor)

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

	func sort(attributes: [Metadata.Attribute], traitOrder: [String]?) -> [Metadata.Attribute]? {
		guard let traitOrder else { return attributes.sorted(at: { $0.traitType ?? "" }, by: <) } // just sort alphabetically
		guard let sorted = attributes.sort(where: \.identity, orderSample: traitOrder, shouldCover: true) else { return nil } // fail
		return sorted // ok
	}
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
