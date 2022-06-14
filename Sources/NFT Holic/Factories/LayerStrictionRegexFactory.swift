import Regex

struct LayerStrictionRegexFactory {

	let layerStrictions: [AssetConfig.Combination]

	func validItemNameRegex(forLayer layer: String, conditionLayers: [InputData.ImageLayer]) -> Regex? {
		let names = conditionLayers
		// pick up all related strictions with current layer selections
			.flatMap { conditionLayer in
				layerStrictions.filter { combination in
					conditionLayer =~ combination.target
				}
			}
			.flatMap(\.dependencies)
			.filter { dependency in
				dependency.layer == layer
			}
			.map(\.name)
		guard !names.isEmpty else { return nil }
		return names.map { "(?=\($0))" }.joined().r
	}
}
