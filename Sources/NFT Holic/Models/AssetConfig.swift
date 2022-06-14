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
			let divideByMatches: Bool?
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
		let imageUrlFormat: String
		let defaultNameFormat: String
		let defaultDescriptionFormat: String
		let externalUrlFormat: String?
		@Default<WhiteHexCode> var backgroundColor: String
		@Default<Traits> var traits: Traits
		@Default<Empty> var traitOrder: [String]

		struct Traits: Codable, Equatable, DefaultValueProvider {
			static var `default`: Self = .init()

			@Default<Empty> var texts: [Simple]
			@Default<Empty> var textLabels: [Label<String>]
			@Default<Empty> var dateLabels: [Label<Date>]
			@Default<Empty> var numberLabels: [Label<Decimal>]
			@Default<Empty> var rankedNumbers: [RankedNumber]
			@Default<Empty> var boostNumbers: [BoostNumber]
			@Default<Empty> var boostPercentages: [BoostPercentage]
			@Default<Empty> var rarityPercentages: [RarityPercentage]

			struct Simple: Codable, Equatable {
				let value: String
				let conditions: [Subject]
			}

			struct Label<ValueType>: Codable, Equatable where ValueType: Codable, ValueType: Equatable {
				let trait: String
				let value: ValueType
				let conditions: [Subject]
			}

			struct RankedNumber: Codable, Equatable {
				let trait: String
				let value: Decimal
				let conditions: [Subject]
			}

			struct BoostNumber: Codable, Equatable {
				let trait: String
				let value: Decimal
				let max: Decimal
				let conditions: [Subject]
			}

			struct BoostPercentage: Codable, Equatable {
				let trait: String
				let value: Decimal
				let conditions: [Subject]
			}

			struct RarityPercentage: Codable, Equatable {
				let trait: String
				let conditions: [Subject]
			}
		}
	}
}
