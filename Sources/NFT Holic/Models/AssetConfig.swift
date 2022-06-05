import CoreGraphics

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
		let textLabels: [Label<String>]?

		struct Label<ValueType: Decodable>: Decodable {
			let trait: String
			let value: ValueType
			let conditions: [Subject]
		}
	}
}
