import CoreGraphics

struct AssetConfig: Decodable {
	let drawSerial: DrawSerial?

	struct DrawSerial: Decodable {
		let enabled: Bool?
		let format: String?
		let font: String?
		let size: CGFloat?
		let color: String?
		let offsetX: CGFloat?
		let offsetY: CGFloat?
	}
}
