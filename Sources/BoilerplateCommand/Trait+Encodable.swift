import AssetConfig
import Foundation

extension Trait: Encodable {
	enum CodingKeys: CodingKey {
		case type, trait, value, max
	}

	enum TraitType: String, Encodable {
		case simple, label, rankedNumber, boostNumber, boostPercentage, rarityPercentage
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {
			case let .simple(value):
				try container.encode(TraitType.simple, forKey: .type)
				try container.encode(value, forKey: .value)
			case let .label(trait, value):
				try container.encode(TraitType.label, forKey: .type)
				try container.encode(trait, forKey: .trait)
				try container.encode(value, forKey: .value)
			case let .rankedNumber(trait, value):
				try container.encode(TraitType.rankedNumber, forKey: .type)
				try container.encode(trait, forKey: .trait)
				try container.encode(value, forKey: .value)
			case let .boostNumber(trait, value, max):
				try container.encode(TraitType.boostNumber, forKey: .type)
				try container.encode(trait, forKey: .trait)
				try container.encode(value, forKey: .value)
				try container.encode(max, forKey: .max)
			case let .boostPercentage(trait, value):
				try container.encode(TraitType.boostPercentage, forKey: .type)
				try container.encode(trait, forKey: .trait)
				try container.encode(value, forKey: .value)
			case let .rarityPercentage(trait):
				try container.encode(TraitType.rarityPercentage, forKey: .type)
				try container.encode(trait, forKey: .trait)
		}
	}
}
