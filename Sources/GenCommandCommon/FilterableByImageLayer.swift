public protocol FilterableByImageLayer {
	associatedtype Element: ImageLayerSubject
	var subjects: [Element] { get }
}

extension AssetConfig.Combination: FilterableByImageLayer {
	public var subjects: [AssetConfig.Subject] {
		dependencies
	}
}

extension AssetConfig.Metadata.Data: FilterableByImageLayer {
	public var subjects: [AssetConfig.Subject] {
		conditions
	}
}

extension Sequence where Element: FilterableByImageLayer {
	public func filtered(by layer: ImageLayerSubject) -> [Element] {
		filter { element in
			element.subjects.contains { subject in
				subject.contains(layer)
			}
		}
	}
}
