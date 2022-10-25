import Common
import GenCommandCommon
import CollectionKit
import Files
import Foundation
import Regex
import UniformTypeIdentifiers

public struct MetadataFactory {

	private let input: InputData

	public init(input: InputData) {
		self.input = input
	}
}

public extension MetadataFactory {
	/// Generate a metadata json.
	/// - Parameters:
	///   - folder: location to save generated metadata
	///   - serial: will be file name (without path and extension)
	/// - Returns: if success
	@discardableResult
	func generateMetadata(saveIn folder: Folder, as name: String, serial: Int, metadataConfig config: AssetConfig.Metadata, imageFolderName: String, imageType: UTType) -> Result<File, MetadataFactoryError> {
		switch input.assets {
		case let .animated(layers, _):
			return generateMetadata(from: layers, saveIn: folder, as: name, serial: serial, metadataConfig: config, imageFolderName: imageFolderName, imageType: imageType)
		case let .still(layers):
			return generateMetadata(from: layers, saveIn: folder, as: name, serial: serial, metadataConfig: config, imageFolderName: imageFolderName, imageType: imageType)
		}
	}
}

private extension MetadataFactory {

	@discardableResult
	func generateMetadata<F: Location>(from layers: [InputData.ImageLayer<F>], saveIn folder: Folder, as name: String, serial: Int, metadataConfig config: AssetConfig.Metadata, imageFolderName: String, imageType: UTType) -> Result<File, MetadataFactoryError> {
		guard let jsonFile = try? folder.createFileIfNeeded(withName: "\(name).json") else { return .failure(.creatingFileFailed) }
		let attributes = layers.reduce([Metadata.Attribute]()) { accum, layer in
			accum + config.data
				.filtered(by: layer)
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
		// validate
		guard config.backgroundColor =~ #"^[\da-fA-F]{6}$|^[\da-fA-F]{3}$"#.r else {
			try? jsonFile.delete()
			return .failure(.invalidBackgroundColorCode)
		}

		let metadata = Metadata(image: imageURL, externalURL: externalURL, description: description, name: name, attributes: sortedAttribute, backgroundColor: config.backgroundColor)

		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted

		guard let _ = try? jsonFile.write(encoder.encode(metadata)) else {
			try? jsonFile.delete()
			return .failure(.writingFileFailed)
		}
		return .success(jsonFile)
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
		let text = "%\\d*?d".r?.replaceAll(in: format) { match in
			.init(format: match.matched, serial)
		} ?? format

		guard let attributeMatcher = try? Regex(pattern: "\\$\\{(.*?)\\}", groupNames: "attr") else { return text }
		return attributeMatcher.replaceAll(in: text) { match in
			let trait = match.group(named: "attr")
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
		guard let order = traitOrder else { return attributes.sorted(at: { $0.traitType ?? "" }, by: <) } // just sort alphabetically
		guard let sorted = attributes.sort(where: \.identity, orderSample: order, shouldCover: true) else { return nil } // fail
		return sorted // ok
	}
}

public enum MetadataFactoryError: Error {
	case creatingFileFailed
	case imageUrlFormatIsRequired
	case invalidMetadataSortConfig
	case invalidBackgroundColorCode
	case writingFileFailed
}
