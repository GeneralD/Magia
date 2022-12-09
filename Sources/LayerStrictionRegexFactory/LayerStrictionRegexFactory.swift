import AssetConfig
import Files

public struct LayerStrictionRegexFactory {

	private let layerStrictions: [any Combination]

	public init(layerStrictions: [any Combination]) {
		self.layerStrictions = layerStrictions
	}

	public func isValidItem(itemName: String, forLayer layer: String, conditionLayers: some Sequence<some LayerSubject>) -> Bool {
		conditionLayers
		// pick up all related strictions with current layer selections
			.flatMap { conditionLayer in
				layerStrictions.filter { combination in
					combination.target.layer == conditionLayer.layer && conditionLayer.name.contains(combination.target.name)
				}
			}
			.flatMap { $0.dependencies } // keypath \.dependencies triggers a fatal error at runtime by compiler bug
			.filter { dependency in dependency.layer == layer }
			.reduce(true) { accum, dependency in accum && itemName.contains(dependency.name) }
	}
}
