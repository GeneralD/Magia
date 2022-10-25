import Regex

public protocol ImageLayerSubject {
	var layer: String { get }
	var name: String { get }
}

extension AssetConfig.Subject: ImageLayerSubject {}

extension InputData.ImageLayer: ImageLayerSubject {}

public func =~(_ lhs: ImageLayerSubject, _ rhs: ImageLayerSubject) -> Bool {
	lhs.layer == rhs.layer && lhs.name =~ rhs.name
}
