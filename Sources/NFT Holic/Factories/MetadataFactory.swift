import Files
import Foundation
import Regex

struct MetadataFactory {

	let input: InputData

	/// Generate a metadata json.
	/// - Parameters:
	///   - folder: location to save generated metadata
	///   - serial: will be file name (without path and extension)
	/// - Returns: if success
	@discardableResult
	func generateMetadata(saveIn folder: Folder, serial: Int, metadataConfig config: AssetConfig.Metadata) -> Result<File, MetadataFactoryError> {
		guard let jsonFile = try? folder.createFileIfNeeded(withName: "\(serial).json") else { return .failure(.creatingFileFailed) }

		let attributes = input.layers.reduce([Metadata.Attribute]()) { accum, layer in
			let attrs: [[Metadata.Attribute]] = [
				accum,

				config.texts.orEmpty
					.filtered(by: layer)
					.map(\.value)
					.map(Metadata.Attribute.simple(value: )),

				config.textLabels.orEmpty
					.filtered(by: layer)
					.map { label in	.textLabel(traitType: label.trait, value: label.value) },

				config.dateLabels.orEmpty
					.filtered(by: layer)
					.map { label in .dateLabel(traitType: label.trait, value: label.value) },

				config.intLabels.orEmpty
					.filtered(by: layer)
					.map { label in .numberLabel(traitType: label.trait, value: .int(label.value)) },

				config.floatLabels.orEmpty
					.filtered(by: layer)
					.map { label in .numberLabel(traitType: label.trait, value: .float(label.value, digitsAfterPoint: 2)) },

				config.rarityPercentages.orEmpty
					.filtered(by: layer)
					.map { label in .boostPercentage(traitType: label.trait, value: .float(layer.probability * 100, digitsAfterPoint: 2)) },
			]
			return attrs.flatten
		}.unique(where: \.identity)

		// sort attributes
		guard let sortedAttribute = sort(attributes: attributes, traitOrder: config.order?.trait) else {
			try? jsonFile.delete()
			return .failure(.invalidMetadataSortConfig)
		}

		// image url is required field
		guard let imageURL = URL(string: .init(format: config.imageUrlFormat, serial)) else {
			try? jsonFile.delete()
			return .failure(.imageUrlFormatIsRequired)
		}

		// TODO: override defaults values
		let name = String(format: config.defaultNameFormat, serial)
		let description = String(format: config.defaultDescriptionFormat, serial)

		let externalURL = config.externalUrlFormat.map { String(format: $0, serial) }.flatMap(URL.init(string: ))
		let backgroundColor = config.backgroundColor ?? "ffffff"
		// validate
		guard backgroundColor =~ #"^[\da-fA-F]{6}$|^[\da-fA-F]{3}$"#.r else {
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
