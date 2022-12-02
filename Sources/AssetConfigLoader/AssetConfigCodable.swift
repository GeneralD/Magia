import CoreGraphics
import DefaultCodable
import GenCommandCommon
import Foundation

struct AssetConfigCodable: AssetConfig, Codable, Equatable, DefaultValueProvider {
	static let `default`: Self = .init()

	@Default<Nil> var order: OrderCodable?
	@Default<Empty> var combinations: [CombinationCodable]
	@Default<RandomizationCodable> var randomization: RandomizationCodable
	@Default<DrawSerialCodable> var drawSerial: DrawSerialCodable
	@Default<Nil> var metadata: MetadataCodable?

	struct OrderCodable: Order, Codable, Equatable, DefaultValueProvider {
		static let `default`: Self = .init()

		@Default<Nil> var selection: [String]?
		@Default<Nil> var layerDepth: [String]?
	}

	struct CombinationCodable: Combination, Codable, Equatable {
		var subjects: [SubjectCodable] { dependencies }

		let target: SubjectCodable
		let dependencies: [SubjectCodable]
	}

	struct RandomizationCodable: Randomization, Codable, Equatable, DefaultValueProvider {
		static let `default`: Self = .init(probabilities: .init())

		@Default<Empty> var probabilities: [ProbabilityCodable]

		struct ProbabilityCodable: Probability, Codable, Equatable {
			let target: SubjectCodable
			@Default<OneDouble> var weight: Double
			@Default<False> var divideByMatches: Bool
		}
	}

	struct SubjectCodable: Subject, Codable, Equatable {
		let layer: String
		@Default<RegexMatchesNothing> var name: String
	}

	struct DrawSerialCodable: DrawSerial, Codable, Equatable, DefaultValueProvider {
		static let `default`: Self = .init(enabled: .init(wrappedValue: false))

		@Default<True> var enabled: Bool
		@Default<ZeroFillThreeDigitsFormat> var format: String
		@Default<Empty> var font: String
		@Default<FontMidiumSize> var size: CGFloat
		@Default<BlackHexCode> var color: String
		@Default<ZeroFloat> var offsetX: CGFloat
		@Default<ZeroFloat> var offsetY: CGFloat
	}

	struct MetadataCodable: Metadata, Codable, Equatable, DefaultValueProvider {
		static let `default`: Self = .init()

		@Default<BlankURL> var baseUrl: URL
		@Default<Empty> var nameFormat: String
		@Default<Empty> var descriptionFormat: String
		@Default<Nil> var externalUrlFormat: String?
		@Default<WhiteHexCode> var backgroundColor: String
		@Default<Empty> var data: [TraitDataCodable]
		@Default<Empty> var traitOrder: [String]

		struct TraitDataCodable: TraitData, Codable, Equatable {
			var subjects: [SubjectCodable] { conditions }

			let traits: [Trait]
			let conditions: [SubjectCodable]
		}
	}
}

extension Trait: Codable {
	enum CodingKeys: CodingKey {
		case type, trait, value, max
	}

	enum TraitType: String, Codable {
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

	public init(from decoder: Decoder) throws {
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
