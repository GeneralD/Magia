import CoreGraphics
import DefaultCodable
import Foundation

struct AssetConfig: Codable, Equatable {
	static let empty: Self = .init(order: nil, combinations: .init(), randomization: .init(), drawSerial: .default, metadata: nil)
	
	let order: Order?
	@Default<Empty> var combinations: [Combination]
	@Default<Randomization> var randomization: Randomization
	let drawSerial: DrawSerial
	let metadata: Metadata?

	struct Combination: Codable, Equatable {
		let target: Subject
		let dependencies: [Subject]
	}

	struct Subject: Codable, Equatable {
		let layer: String
		@Default<RegexMatchesNothing> var name: String
	}

	struct Randomization: Codable, Equatable, DefaultValueProvider {
		static var `default`: Self = .init(probabilities: .init())

		@Default<Empty> var probabilities: [Probability]

		struct Probability: Codable, Equatable {
			let target: Subject
			@Default<OneDouble> var weight: Double
			@Default<False> var divideByMatches: Bool
		}
	}

	struct DrawSerial: Codable, Equatable, DefaultValueProvider {
		static var `default`: Self = .init()

		@Default<True> var enabled: Bool
		@Default<ZeroFillThreeDigitsFormat> var format: String
		@Default<Empty> var font: String
		@Default<FontMidiumSize> var size: CGFloat
		@Default<BlackHexCode> var color: String
		@Default<ZeroFloat> var offsetX: CGFloat
		@Default<ZeroFloat> var offsetY: CGFloat
	}

	struct Order: Codable, Equatable {
		let selection: [String]?
		let layerDepth: [String]?
	}

	struct Metadata: Codable, Equatable {
		let baseUrl: URL
		let nameFormat: String
		let descriptionFormat: String
		let externalUrlFormat: String?
		@Default<WhiteHexCode> var backgroundColor: String
		@Default<Empty> var data: [Data]
		@Default<Empty> var traitOrder: [String]

		struct Data: Codable, Equatable {
			let traits: [Trait]
			let conditions: [Subject]
		}

		enum Trait: Codable, Equatable {
			case simple(value: String)
			case label(trait: String, value: LabelValueType)
			case rankedNumber(trait: String, value: Decimal)
			case boostNumber(trait: String, value: Decimal, max: Decimal)
			case boostPercentage(trait: String, value: Decimal)
			case rarityPercentage(trait: String)

			enum LabelValueType: Codable, Equatable {
				case string(_: String)
				case date(_: Date)
				case number(_: Decimal)
			}

			enum CodingKeys: CodingKey {
				case type, trait, value, max
			}

			enum TraitType: String, Codable {
				case simple, label, rankedNumber, boostNumber, boostPercentage, rarityPercentage
			}

			func encode(to encoder: Encoder) throws {
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

			init(from decoder: Decoder) throws {
				let container = try decoder.container(keyedBy: CodingKeys.self)
				let type = try container.decode(TraitType.self, forKey: .type)
				switch type {
				case .simple:
					self = try .simple(value: container.decode(String.self, forKey: .value))
				case .label:
					let value = try? container.decodeIfPresent(Date.self, forKey: .value).flatMap(LabelValueType.date)
					?? container.decodeIfPresent(Decimal.self, forKey: .value).flatMap(LabelValueType.number)
					self = try .label(trait: container.decode(String.self, forKey: .trait), value: value ?? .string(container.decode(String.self, forKey: .value)))
				case .rankedNumber:
					self = try .rankedNumber(trait: container.decode(String.self, forKey: .trait), value: container.decode(Decimal.self, forKey: .value))
				case .boostNumber:
					self = try .boostNumber(trait: container.decode(String.self, forKey: .trait), value: container.decode(Decimal.self, forKey: .value), max: container.decode(Decimal.self, forKey: .max))
				case .boostPercentage:
					self = try .boostPercentage(trait: container.decode(String.self, forKey: .trait), value: container.decode(Decimal.self, forKey: .value))
				case .rarityPercentage:
					self = try .rarityPercentage(trait: container.decode(String.self, forKey: .trait))
				}
			}
		}
	}
}
