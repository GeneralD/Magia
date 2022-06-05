import Regex

struct LayerStrictionRegexFactory {

	let layerStrictions: [AssetConfig.Combination]?

	func validItemNameRegex(forLayer layer: String, conditionLayers: [InputData.ImageLayer]) -> Regex? {
		// check if no striction
		guard let combinations = layerStrictions else { return nil }

		let names = conditionLayers
		// pick up all related strictions with current layer selections
			.flatMap { conditionLayer in
				combinations.filter { combination in
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
