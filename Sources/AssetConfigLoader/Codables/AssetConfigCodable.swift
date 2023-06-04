import AssetConfig
import DefaultCodable
import Foundation

struct AssetConfigCodable: CommonAssetConfig, SummonAssetConfig, EnchantAssetConfig, Codable, Equatable, DefaultValueProvider {
	static let `default`: Self = .init()

	@Default<OrderCodable> var order: OrderCodable
	@Default<Empty> var combinations: [CombinationCodable]
	@Default<Empty> var specials: [SpecialCodable]
	@Default<RandomizationCodable> var randomization: RandomizationCodable
	@Default<DrawSerialCodable> var drawSerial: DrawSerialCodable
	@Default<MetadataCodable> var metadata: MetadataCodable
	@Default<EnchantSingleAssetElection> var singleAsset: EnchantSingleAssetElection

	struct OrderCodable: SummonOrder, Codable, Equatable, DefaultValueProvider {
		static let `default`: Self = .init()

		@Default<Nil> var selection: [String]?
		@Default<Nil> var layerDepth: [String]?
	}

	struct CombinationCodable: SummonCombination, Codable, Equatable {
		let target: SubjectCodable
		let dependencies: [SubjectCodable]
	}

	struct SpecialCodable: SummonSpecial, Codable, Equatable {
		let index: Int
		let dependencies: [SubjectCodable]
	}

	struct RandomizationCodable: SummonRandomization, Codable, Equatable, DefaultValueProvider {
		static let `default`: Self = .init(probabilities: .init())

		@Default<Empty> var probabilities: [ProbabilityCodable]
		@Default<Empty> var allocations: [AllocationCodable]

		struct ProbabilityCodable: SummonProbability, Codable, Equatable {
			let target: SubjectCodable
			@Default<OneDouble> var weight: Double
			@Default<False> var divideByMatches: Bool
		}

		struct AllocationCodable: SummonAllocation, Codable, Equatable {
			let target: SubjectCodable
			let quantity: Int
		}
	}

	struct SubjectCodable: CommonSubject, Codable, Equatable {
		/// default: #/^(?!)$/#
		let layer: Regex<AnyRegexOutput>
		/// default: #/^(?!)$/#
		let name: Regex<AnyRegexOutput>
		/// to just keep original string to compare 2 objects
		private let layerExpression: String
		private let nameExpression: String

		enum CodingKeys: CodingKey {
			case layer, name
		}

		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			try container.encode(layerExpression, forKey: .layer)
			try container.encode(nameExpression, forKey: .name)
		}

		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			layerExpression = try container.decodeIfPresent(String.self, forKey: .layer) ?? "^(?!)$"
			nameExpression = try container.decodeIfPresent(String.self, forKey: .name) ?? "^(?!)$"
			layer = try Regex(layerExpression)
			name = try Regex(nameExpression)
		}

		static func == (lhs: Self, rhs: Self) -> Bool {
			lhs.layerExpression == rhs.layerExpression && lhs.nameExpression == rhs.nameExpression
		}
	}

	struct DrawSerialCodable: SummonDrawSerial, Codable, Equatable, DefaultValueProvider {
		static let `default`: Self = .init(enabled: .init(wrappedValue: false))

		@Default<True> var enabled: Bool
		@Default<ZeroFillThreeDigitsFormat> var format: String
		@Default<Empty> var font: String
		@Default<FontMidiumSize> var size: CGFloat
		@Default<BlackHexCode> var color: String
		@Default<ZeroFloat> var offsetX: CGFloat
		@Default<ZeroFloat> var offsetY: CGFloat
	}

	struct MetadataCodable: CommonMetadata, EnchantMetadata, Codable, Equatable, DefaultValueProvider {
		static let `default`: Self = .init()

		@Default<Nil> var baseUrl: URL?
		@Default<Empty> var nameFormat: String
		@Default<Empty> var descriptionFormat: String
		@Default<Nil> var externalUrlFormat: String?
		@Default<WhiteHexCode> var backgroundColor: String
		@Default<Empty> var traitData: [TraitDataCodable]
		@Default<Empty> var traitOrder: [String]
		@Default<Empty> var aiTraitData: [EnchantTraitDataCodable]
		@Default<EnchantTraitListingCodable> var aiTraitListing: EnchantTraitListingCodable

		struct TraitDataCodable: CommonTraitData, Codable, Equatable {
			let traits: [CommonTrait]
			let conditions: [SubjectCodable]
		}

		struct EnchantTraitDataCodable: EnchantTraitData, Codable, Equatable {
			/// default: empty
			let traits: [CommonTrait]
			/// default: #/^(?!)$/#
			let spell: Regex<AnyRegexOutput>
			/// to just keep original string to compare 2 objects
			private let spellExpression: String

			enum CodingKeys: CodingKey {
				case traits, spell
			}

			func encode(to encoder: Encoder) throws {
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode(traits, forKey: .traits)
				try container.encode(spellExpression, forKey: .spell)
			}

			init(from decoder: Decoder) throws {
				let container = try decoder.container(keyedBy: CodingKeys.self)
				traits = try container.decodeIfPresent([CommonTrait].self, forKey: .traits) ?? []
				spellExpression = try container.decodeIfPresent(String.self, forKey: .spell) ?? "^(?!)$"
				spell = try Regex(spellExpression)
			}

			static func == (lhs: Self, rhs: Self) -> Bool {
				lhs.spellExpression == rhs.spellExpression && lhs.traits == rhs.traits
			}
		}

		struct EnchantTraitListingCodable: EnchantTraitListing, Codable, Equatable, DefaultValueProvider {
			static let `default`: Self = .init()

			let intent: EnchantTraitListingIntent
			let list: [Regex<AnyRegexOutput>]
			private let listExpressions: [String]

			private init() {
				intent = .blocklist
				list = []
				listExpressions = []
			}

			enum CodingKeys: CodingKey {
				case intent, list
			}

			func encode(to encoder: Encoder) throws {
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encode(intent, forKey: .intent)
				try container.encode(listExpressions, forKey: .list)
			}

			init(from decoder: Decoder) throws {
				let container = try decoder.container(keyedBy: CodingKeys.self)
				intent = try container.decode(EnchantTraitListingIntent.self, forKey: .intent)
				listExpressions = try container.decode([String].self, forKey: .list)
				list = try listExpressions.map(Regex.init)
			}

			static func == (lhs: Self, rhs: Self) -> Bool {
				lhs.intent == rhs.intent && lhs.listExpressions == rhs.listExpressions
			}
		}
	}
}
