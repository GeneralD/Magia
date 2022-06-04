import CoreGraphics

struct AssetConfig: Decodable {
	let order: Order?
	let combinations: [Combination]?
	let drawSerial: DrawSerial?

	struct Combination: Decodable {
		let target: Subject
		let dependencies: [Subject]

		struct Subject: Decodable {
			let layer: String
			let name: String
		}
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
}
