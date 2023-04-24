import AssetConfig
import Foundation

struct BoilerplateAssetConfig: SummonAssetConfig, Encodable {
	let order: BoilerplateOrder
	let combinations: [BoilerplateCombination]
	let specials: [BoilerplateSpecial]
	let randomization: BoilerplateRandomization
	let drawSerial: BoilerplateDrawSerial
	let metadata: BoilerplateMetadata

	struct BoilerplateOrder: SummonOrder, Encodable {
		let selection: [String]?
		let layerDepth: [String]?
	}

	struct BoilerplateCombination: SummonCombination, Encodable {
		let target: BoilerplateSubject
		let dependencies: [BoilerplateSubject]
	}

	struct BoilerplateSpecial: SummonSpecial, Encodable {
		let index: Int
		let dependencies: [BoilerplateSubject]
	}

	struct BoilerplateRandomization: SummonRandomization, Encodable {
		let probabilities: [BoilerplateProbability]
		let allocations: [BoilerplateAllocation]

		struct BoilerplateProbability: SummonProbability, Encodable {
			let target: BoilerplateSubject
			let weight: Double
			let divideByMatches: Bool
		}

		struct BoilerplateAllocation: SummonAllocation, Encodable {
			let target: BoilerplateSubject
			let quantity: Int
		}
	}

	struct BoilerplateDrawSerial: SummonDrawSerial, Encodable {
		let enabled: Bool
		let format: String
		let font: String
		let size: CGFloat
		let color: String
		let offsetX: CGFloat
		let offsetY: CGFloat
	}

	struct BoilerplateMetadata: CommonMetadata, Encodable {
		let baseUrl: URL
		let nameFormat: String
		let descriptionFormat: String
		let externalUrlFormat: String?
		let backgroundColor: String
		let traitData: [BoilerplateTraitData]
		let traitOrder: [String]

		struct BoilerplateTraitData: CommonTraitData, Encodable {
			let traits: [CommonTrait]
			let conditions: [BoilerplateSubject]
		}
	}

	struct BoilerplateSubject: CommonSubject, Encodable {
		/// default: #/^(?!)$/#
		let layer: Regex<AnyRegexOutput>
		/// default: #/^(?!)$/#
		let name: Regex<AnyRegexOutput>
		/// to just keep original string to compare 2 objects
		private let layerExpression: String
		private let nameExpression: String

		init(layerExpression: String, nameExpression: String) throws {
			self.layerExpression = layerExpression
			self.nameExpression = nameExpression
			layer = try Regex(layerExpression)
			name = try Regex(nameExpression)
		}

		enum CodingKeys: CodingKey {
			case layer, name
		}

		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			try container.encode(layerExpression, forKey: .layer)
			try container.encode(nameExpression, forKey: .name)
		}
	}
}
