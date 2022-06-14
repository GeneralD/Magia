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

				config.traits.texts
					.filtered(by: layer)
					.map(\.value)
					.map(Metadata.Attribute.simple(value: )),

				config.traits.textLabels
					.filtered(by: layer)
					.map { conf in	.textLabel(traitType: conf.trait, value: conf.value) },

				config.traits.dateLabels
					.filtered(by: layer)
					.map { conf in .dateLabel(traitType: conf.trait, value: conf.value) },

				config.traits.numberLabels
					.filtered(by: layer)
					.map { conf in .numberLabel(traitType: conf.trait, value: conf.value) },

				config.traits.rankedNumbers
					.filtered(by: layer)
					.map { conf in .rankedNumber(traitType: conf.trait, value: conf.value) },

				config.traits.boostNumbers
					.filtered(by: layer)
					.map { conf in .boostNumber(traitType: conf.trait, value: conf.value, maxValue: conf.max) },

				config.traits.boostPercentages
					.filtered(by: layer)
					.map { conf in .boostPercentage(traitType: conf.trait, value: conf.value) },

				config.traits.rarityPercentages
					.filtered(by: layer)
					.map { conf in .boostPercentage(traitType: conf.trait, value: .init(layer.probability * 100, digitsAfterPoint: 2)) },
			]
			return attrs.flatten
		}.unique(where: \.identity)

		// sort attributes
		guard let sortedAttribute = sort(attributes: attributes, traitOrder: config.traitOrder) else {
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
