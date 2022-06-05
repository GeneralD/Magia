import CoreGraphics
import Foundation

struct AssetConfig: Decodable {
	static let empty: Self = .init(order: nil, combinations: nil, drawSerial: nil, metadata: nil)
	
	let order: Order?
	let combinations: [Combination]?
	let drawSerial: DrawSerial?
	let metadata: Metadata?

	struct Combination: Decodable {
		let target: Subject
		let dependencies: [Subject]
	}

	struct Subject: Decodable {
		let layer: String
		let name: String
	}

	struct DrawSerial: Decodable {
		let enabled: Bool?
		let format: String?
		let font: String?
		let size: CGFloat?
		let color: String?
		let offsetX: CGFloat?
		let offsetY: CGFloat?
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
		let texts: [Simple]?
		let textLabels: [Label<String>]?
		let dateLabels: [Label<Date>]?
		let intLabels: [Label<Int>]?
		let floatLabels: [Label<Float>]?
		let order: Order?

		struct Label<ValueType: Decodable>: Decodable {
			let trait: String
			let value: ValueType
			let conditions: [Subject]
		}

		struct Simple: Decodable {
			let value: String
			let conditions: [Subject]
		}

		struct Order: Decodable {
			let trait: [String]?
		}
	}
}
