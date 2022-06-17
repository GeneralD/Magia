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

extension AssetConfig.Metadata.Traits.Label: FilterableByImageLayer {
	typealias Element = AssetConfig.Subject
	var subjects: [Element] {
		conditions
	}
}

extension AssetConfig.Metadata.Traits.Simple: FilterableByImageLayer {
	typealias Element = AssetConfig.Subject
	var subjects: [AssetConfig.Subject] {
		conditions
	}
}

extension AssetConfig.Metadata.Traits.RankedNumber: FilterableByImageLayer {
	typealias Element = AssetConfig.Subject
	var subjects: [AssetConfig.Subject] {
		conditions
	}
}

extension AssetConfig.Metadata.Traits.BoostNumber: FilterableByImageLayer {
	typealias Element = AssetConfig.Subject
	var subjects: [AssetConfig.Subject] {
		conditions
	}
}

extension AssetConfig.Metadata.Traits.BoostPercentage: FilterableByImageLayer {
	typealias Element = AssetConfig.Subject
	var subjects: [AssetConfig.Subject] {
		conditions
	}
}

extension AssetConfig.Metadata.Traits.RarityPercentage: FilterableByImageLayer {
	typealias Element = AssetConfig.Subject
	var subjects: [AssetConfig.Subject] {
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
