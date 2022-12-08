import AssetConfig
import Files

public struct LayerStrictionRegexFactory {

	private let layerStrictions: [any Combination]

	public init(layerStrictions: [any Combination]) {
		self.layerStrictions = layerStrictions
	}

	public func validItemNameRegex(forLayer layer: String, conditionLayers: some Sequence<some LayerSubject>) -> Regex<Substring>? {
		let names = conditionLayers
		// pick up all related strictions with current layer selections
			.flatMap { conditionLayer in
				layerStrictions.filter { combination in
					guard let regex = try? Regex(combination.target.name) else { return false }
					return combination.target.layer == conditionLayer.layer && conditionLayer.name.contains(regex)
				}
			}
			.flatMap { $0.dependencies } // keypath \.dependencies triggers a fatal error at runtime by compiler bug
			.filter { dependency in
				dependency.layer == layer
			}
			.map(\.name)
		return try? Regex(names.map { "(?=\($0))" }.joined())
	}
}
