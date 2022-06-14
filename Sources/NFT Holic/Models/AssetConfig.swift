import CoreGraphics
import DefaultCodable
import Foundation

struct AssetConfig: Decodable {
	static let empty: Self = .init(order: nil, combinations: nil, randomization: nil, drawSerial: .default, metadata: nil)
	
	let order: Order?
	let combinations: [Combination]?
	let randomization: Randomization?
	let drawSerial: DrawSerial
	let metadata: Metadata?

	struct Combination: Decodable {
		let target: Subject
		let dependencies: [Subject]
	}

	struct Subject: Codable, Equatable {
		let layer: String
		@Default<RegexMatchesNothing> var name: String
	}

	struct Randomization: Decodable {
		let probabilities: [Probability]

		struct Probability: Decodable {
			let target: Subject
			let weight: Double
			let divideByMatches: Bool?
		}
	}

	struct DrawSerial: Codable, Equatable, DefaultValueProvider {
		@Default<True> var enabled: Bool
		@Default<ZeroFillThreeDigitsFormat> var format: String
		@Default<Empty> var font: String
		@Default<FontMidiumSize> var size: CGFloat
		@Default<BlackHexCode> var color: String
		@Default<Zero> var offsetX: CGFloat
		@Default<Zero> var offsetY: CGFloat

		static var `default`: Self = .init()
	}

	struct Order: Decodable {
		let selection: [String]?
		let layerDepth: [String]?
	}

	struct Metadata: Decodable {
		let imageUrlFormat: String
		let defaultNameFormat: String
		let defaultDescriptionFormat: String
		let externalUrlFormat: String?
		let backgroundColor: String?
		@Default<Traits> var traits: Traits
		@Default<Empty> var traitOrder: [String]

		struct Traits: Codable, Equatable, DefaultValueProvider {
			@Default<Empty> var texts: [Simple]
			@Default<Empty> var textLabels: [Label<String>]
			@Default<Empty> var dateLabels: [Label<Date>]
			@Default<Empty> var numberLabels: [Label<Decimal>]
			@Default<Empty> var rankedNumbers: [RankedNumber]
			@Default<Empty> var boostNumbers: [BoostNumber]
			@Default<Empty> var boostPercentages: [BoostPercentage]
			@Default<Empty> var rarityPercentages: [RarityPercentage]

			static var `default`: Self = .init()

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
