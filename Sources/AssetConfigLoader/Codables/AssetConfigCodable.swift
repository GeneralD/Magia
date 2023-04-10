import AssetConfig
import DefaultCodable
import Foundation

struct AssetConfigCodable: AssetConfig, Codable, Equatable, DefaultValueProvider {
	static let `default`: Self = .init()

	@Default<OrderCodable> var order: OrderCodable
	@Default<Empty> var combinations: [CombinationCodable]
	@Default<RandomizationCodable> var randomization: RandomizationCodable
	@Default<DrawSerialCodable> var drawSerial: DrawSerialCodable
	@Default<MetadataCodable> var metadata: MetadataCodable
	@Default<SingleAssetElection> var singleAsset: SingleAssetElection

	struct OrderCodable: Order, Codable, Equatable, DefaultValueProvider {
		static let `default`: Self = .init()

		@Default<Nil> var selection: [String]?
		@Default<Nil> var layerDepth: [String]?
	}

	struct CombinationCodable: Combination, Codable, Equatable {
		let target: SubjectCodable
		let dependencies: [SubjectCodable]
	}

	struct RandomizationCodable: Randomization, Codable, Equatable, DefaultValueProvider {
		static let `default`: Self = .init(probabilities: .init())

		@Default<Empty> var probabilities: [ProbabilityCodable]
		@Default<Nil> var reservation: ReservationCodable?

		struct ProbabilityCodable: Probability, Codable, Equatable {
			let target: SubjectCodable
			@Default<OneDouble> var weight: Double
			@Default<False> var divideByMatches: Bool
		}

		struct ReservationCodable: Reservation, Codable, Equatable {
			let layer: String
			@Default<Empty> var allocations: [AllocationCodable]

			struct AllocationCodable: Allocation, Codable, Equatable {
				let name: String
				let weight: Double
			}
		}
	}

	struct SubjectCodable: Subject, Codable, Equatable {
		/// default: empty
		let layer: String
		/// default: #/^(?!)$/#
		let name: Regex<AnyRegexOutput>
		/// to just keep original string to compare 2 objects
		private let nameExpression: String

		enum CodingKeys: CodingKey {
			case layer, name
		}

		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			try container.encode(layer, forKey: .layer)
			try container.encode(nameExpression, forKey: .name)
		}

		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			layer = try container.decodeIfPresent(String.self, forKey: .layer) ?? ""
			nameExpression = try container.decodeIfPresent(String.self, forKey: .name) ?? "^(?!)$"
			name = try Regex(nameExpression)
		}

		static func == (lhs: Self, rhs: Self) -> Bool {
			lhs.layer == rhs.layer && lhs.nameExpression == rhs.nameExpression
		}
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
		@Default<Empty> var traitData: [TraitDataCodable]
		@Default<Empty> var traitOrder: [String]
		@Default<Empty> var aiTraitData: [AITraitDataCodable]
		@Default<AITraitListingCodable> var aiTraitListing: AITraitListingCodable

		struct TraitDataCodable: TraitData, Codable, Equatable {
			let traits: [Trait]
			let conditions: [SubjectCodable]
		}

		struct AITraitDataCodable: AITraitData, Codable, Equatable {
			/// default: empty
			let traits: [Trait]
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
				traits = try container.decodeIfPresent([Trait].self, forKey: .traits) ?? []
				spellExpression = try container.decodeIfPresent(String.self, forKey: .spell) ?? "^(?!)$"
				spell = try Regex(spellExpression)
			}

			static func == (lhs: Self, rhs: Self) -> Bool {
				lhs.spellExpression == rhs.spellExpression && lhs.traits == rhs.traits
			}
		}

		struct AITraitListingCodable: AITraitListing, Codable, Equatable, DefaultValueProvider {
			static let `default`: Self = .init()

			let intent: AITraitListingIntent
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
				intent = try container.decode(AITraitListingIntent.self, forKey: .intent)
				listExpressions = try container.decode([String].self, forKey: .list)
				list = try listExpressions.map(Regex.init)
			}

			static func == (lhs: Self, rhs: Self) -> Bool {
				lhs.intent == rhs.intent && lhs.listExpressions == rhs.listExpressions
			}
		}
	}
}
