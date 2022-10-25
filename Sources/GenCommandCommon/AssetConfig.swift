import CoreGraphics
import DefaultCodable
import Foundation

public struct AssetConfig: Codable, Equatable {
	public static let empty: Self = .init(order: nil, combinations: .init(), randomization: .init(), drawSerial: .default, metadata: nil)
	
	public let order: Order?
	@Default<Empty> public var combinations: [Combination]
	@Default<Randomization> public var randomization: Randomization
	public let drawSerial: DrawSerial
	public let metadata: Metadata?

	public struct Combination: Codable, Equatable {
		public let target: Subject
		public let dependencies: [Subject]
	}

	public struct Subject: Codable, Equatable {
		public let layer: String
		@Default<RegexMatchesNothing> public var name: String
	}

	public struct Randomization: Codable, Equatable, DefaultValueProvider {
		static public var `default`: Self = .init(probabilities: .init())

		@Default<Empty> public var probabilities: [Probability]

		public struct Probability: Codable, Equatable {
			public let target: Subject
			@Default<OneDouble> public var weight: Double
			@Default<False> public var divideByMatches: Bool
		}
	}

	public struct DrawSerial: Codable, Equatable, DefaultValueProvider {
		static public var `default`: Self = .init()

		@Default<True> public var enabled: Bool
		@Default<ZeroFillThreeDigitsFormat> public var format: String
		@Default<Empty> public var font: String
		@Default<FontMidiumSize> public var size: CGFloat
		@Default<BlackHexCode> public var color: String
		@Default<ZeroFloat> public var offsetX: CGFloat
		@Default<ZeroFloat> public var offsetY: CGFloat
	}

	public struct Order: Codable, Equatable {
		public let selection: [String]?
		public let layerDepth: [String]?
	}

	public struct Metadata: Codable, Equatable {
		public let baseUrl: URL
		public let nameFormat: String
		public let descriptionFormat: String
		public let externalUrlFormat: String?
		@Default<WhiteHexCode> public var backgroundColor: String
		@Default<Empty> public var data: [Data]
		@Default<Empty> public var traitOrder: [String]

		public struct Data: Codable, Equatable {
			public let traits: [Trait]
			public let conditions: [Subject]
		}

		public enum Trait: Codable, Equatable {
			case simple(value: String)
			case label(trait: String, value: LabelValueType)
			case rankedNumber(trait: String, value: Decimal)
			case boostNumber(trait: String, value: Decimal, max: Decimal)
			case boostPercentage(trait: String, value: Decimal)
			case rarityPercentage(trait: String)

			public enum LabelValueType: Codable, Equatable {
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
	}
}
