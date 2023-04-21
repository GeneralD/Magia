import AssetConfig
import DefaultCodable
import Foundation

extension EnchantSingleAssetElection: Codable {
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
		case .alphabetical:
			try container.encode(ElectionType.alphabetical)
		case .shuffle(.duplicatable):
			try container.encode(ElectionType.duplicatableShuffle)
		case .shuffle(.unique):
			try container.encode(ElectionType.uniqueShuffle)
		}
	}


	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		switch try container.decode(ElectionType.self) {
		case .alphabetical:
			self = .alphabetical
		case .duplicatableShuffle:
			self = .shuffle(.duplicatable)
		case .uniqueShuffle:
			self = .shuffle(.unique)
		}
	}

	enum ElectionType: String, Codable {
		case alphabetical, duplicatableShuffle, uniqueShuffle
	}
}

extension EnchantSingleAssetElection: DefaultValueProvider {
	public static let `default`: Self = .shuffle(.unique)
}
