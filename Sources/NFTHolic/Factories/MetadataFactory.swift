import Files
import Foundation
import Regex
import UniformTypeIdentifiers

struct MetadataFactory {

	let input: InputData

	/// Generate a metadata json.
	/// - Parameters:
	///   - folder: location to save generated metadata
	///   - serial: will be file name (without path and extension)
	/// - Returns: if success
	@discardableResult
	func generateMetadata(saveIn folder: Folder, serial: Int, metadataConfig config: AssetConfig.Metadata, imageFolderName: String, imageType: UTType) -> Result<File, MetadataFactoryError> {
		switch input.assets {
		case let .animated(layers, _):
			return generateMetadata(from: layers, saveIn: folder, serial: serial, metadataConfig: config, imageFolderName: imageFolderName, imageType: imageType)
		case let .still(layers):
			return generateMetadata(from: layers, saveIn: folder, serial: serial, metadataConfig: config, imageFolderName: imageFolderName, imageType: imageType)
		}
	}
}

private extension MetadataFactory {

	@discardableResult
	func generateMetadata<F: Location>(from layers: [InputData.ImageLayer<F>], saveIn folder: Folder, serial: Int, metadataConfig config: AssetConfig.Metadata, imageFolderName: String, imageType: UTType) -> Result<File, MetadataFactoryError> {
		guard let jsonFile = try? folder.createFileIfNeeded(withName: "\(serial).json") else { return .failure(.creatingFileFailed) }
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
			.appendingPathComponent(serial.description, conformingTo: imageType)

		// TODO: override defaults values
		let name = String(format: config.defaultNameFormat, serial)
		let description = String(format: config.defaultDescriptionFormat, serial)

		let externalURL = config.externalUrlFormat.map { String(format: $0, serial) }.flatMap(URL.init(string: ))
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

	func sort(attributes: [Metadata.Attribute], traitOrder: [String]?) -> [Metadata.Attribute]? {
		guard let order = traitOrder else { return attributes.sorted(at: { $0.traitType ?? "" }, by: <) } // just sort alphabetically
		guard let sorted = attributes.sort(where: \.traitType, orderSample: order, shouldCover: true) else { return nil } // fail
		return sorted // ok
	}
}

enum MetadataFactoryError: Error {
	case creatingFileFailed
	case imageUrlFormatIsRequired
	case invalidMetadataSortConfig
	case invalidBackgroundColorCode
	case writingFileFailed
}
