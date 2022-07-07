import Regex

protocol FilterableByImageLayer {
	associatedtype Element: ImageLayerSubject
	var subjects: [Element] { get }
}

extension AssetConfig.Combination: FilterableByImageLayer {
	typealias Element = AssetConfig.Subject
	var subjects: [Element] {
		dependencies
	}
}

extension AssetConfig.Metadata.Data: FilterableByImageLayer {
	typealias Element = AssetConfig.Subject
	var subjects: [Element] {
		conditions
	}
}

extension Sequence where Element: FilterableByImageLayer {
	func filtered(by layer: ImageLayerSubject) -> [Element] {
		filter { element in
			element.subjects.contains { subject in
				layer =~ subject
			}
		}
	}
}
