import Files
import GenCommandCommon

public struct LayerStrictionRegexFactory {

	private let layerStrictions: [AssetConfig.Combination]

	public init(layerStrictions: [AssetConfig.Combination]) {
		self.layerStrictions = layerStrictions
	}

	public func validItemNameRegex(forLayer layer: String, conditionLayers: [InputData.ImageLayer<some Location>]) -> Regex<Substring>? {
		let names = conditionLayers
		// pick up all related strictions with current layer selections
			.flatMap { conditionLayer in
				layerStrictions.filter { combination in
					combination.target.contains(conditionLayer)
				}
			}
			.flatMap(\.dependencies)
			.filter { dependency in
				dependency.layer == layer
			}
			.map(\.name)
		return try? Regex(names.map { "(?=\($0))" }.joined())
	}
}
