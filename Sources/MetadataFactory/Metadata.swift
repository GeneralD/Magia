import Foundation

struct Metadata: Encodable {
	/// This is the URL to the image of the item.
	/// Can be just about any type of image (including SVGs, which will be cached into PNGs by OpenSea),
	/// and can be IPFS URLs or paths. We recommend using a 350 x 350 image.
	let imageURL: URL

	///	This is the URL that will appear below the asset's image on OpenSea and will allow users to leave OpenSea and view the item on your site.
	let externalURL: URL?

	/// A human readable description of the item. Markdown is supported.
	let description: String

	/// Name of the item.
	let name: String

	/// These are the attributes for the item, which will show up on the OpenSea page for the item.
	let attributes: [Attribute]

	/// Background color of the item on OpenSea. Must be a six-character hexadecimal without a pre-pended #.
	let backgroundColor: String

	enum CodingKeys: String, CodingKey {
		case imageURL = "image"
		case externalURL = "external_url"
		case description
		case name
		case attributes
		case backgroundColor = "background_color"
	}

	/// - SeeAlso: [Document](https://docs.opensea.io/docs/metadata-standards#attributes)
	enum Attribute: Encodable {
		case simple(value: String)
		case textLabel(traitType: String, value: String)
		case dateLabel(traitType: String, value: Date)
		case numberLabel(traitType: String, value: Decimal)
		case boostNumber(traitType: String, value: Decimal, maxValue: Decimal)
		case boostPercentage(traitType: String, value: Decimal)
		case rankedNumber(traitType: String, value: Decimal)

		enum CodingKeys: String, CodingKey {
			case traitType = "trait_type"
			case displayType = "display_type"
			case value
			case maxValue = "max_value"
		}

		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			switch self {
			case let .simple(value):
				try container.encode(value, forKey: .value)

			case let .textLabel(traitType, value):
				try container.encode(traitType, forKey: .traitType)
				try container.encode(value, forKey: .value)

			case let .dateLabel(traitType, value):
				try container.encode(traitType, forKey: .traitType)
				try container.encode("date", forKey: .displayType)
				try container.encode(Int(value.timeIntervalSince1970), forKey: .value)

			case let .numberLabel(traitType, value):
				try container.encode(traitType, forKey: .traitType)
				try container.encode("number", forKey: .displayType)
				try container.encode(value, forKey: .value)

			case let .boostNumber(traitType, value, maxValue):
				try container.encode(traitType, forKey: .traitType)
				try container.encode("boost_number", forKey: .displayType)
				try container.encode(value, forKey: .value)
				try container.encode(maxValue, forKey: .maxValue)

			case let .boostPercentage(traitType, value):
				try container.encode(traitType, forKey: .traitType)
				try container.encode("boost_percentage", forKey: .displayType)
				try container.encode(value, forKey: .value)

			case let .rankedNumber(traitType, value):
				try container.encode(traitType, forKey: .traitType)
				try container.encode(value, forKey: .value)
			}
		}

		/// Userful to distinct attributes.
		var identity: String {
			guard case .simple(value: let value) = self else { return traitType ?? "" }
			return value // use value instead
		}

		var traitType: String? {
			switch self {
			case .simple(value: _):
				return nil
			case .textLabel(traitType: let traitType, value: _):
				return traitType
			case .dateLabel(traitType: let traitType, value: _):
				return traitType
			case .numberLabel(traitType: let traitType, value: _):
				return traitType
			case .boostNumber(traitType: let traitType, value: _, maxValue: _):
				return traitType
			case .boostPercentage(traitType: let traitType, value: _):
				return traitType
			case .rankedNumber(traitType: let traitType, value: _):
				return traitType
			}
		}
	}
}
