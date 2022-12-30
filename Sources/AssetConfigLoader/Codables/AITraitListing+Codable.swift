import AssetConfig
import DefaultCodable

extension AITraitListing: Codable {
	enum CodingKeys: CodingKey {
		case type, spells
	}

	private enum ListingType: Codable {
		case allowlist, blocklist
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {
		case .allow(let spells):
			try container.encode(ListingType.allowlist, forKey: .type)
			try container.encode(spells, forKey: .spells)
		case .block(let spells):
			try container.encode(ListingType.blocklist, forKey: .type)
			try container.encode(spells, forKey: .spells)
		}
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let spells = try container.decode([String].self, forKey: .spells)
		switch try container.decode(ListingType.self, forKey: .type) {
		case .allowlist:
			self = .allow(spells: spells)
		case .blocklist:
			self = .block(spells: spells)
		}
	}
}

extension AITraitListing: DefaultValueProvider {
	public static let `default`: Self = .block(spells: [])
}
