public protocol ImageLayerSubject {
	var layer: String { get }
	var name: String { get }
}

extension AssetConfig.Subject: ImageLayerSubject {}

extension InputData.ImageLayer: ImageLayerSubject {}

public extension ImageLayerSubject {
	func contains(_ target: ImageLayerSubject) -> Bool {
		guard let regex = try? Regex(name) else { return false }
		return layer == target.layer && target.name.contains(regex)
	}
}
