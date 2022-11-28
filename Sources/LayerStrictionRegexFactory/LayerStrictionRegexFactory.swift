import GenCommandCommon
import Regex
import Files

public struct LayerStrictionRegexFactory {

	private let layerStrictions: [AssetConfig.Combination]

	public init(layerStrictions: [AssetConfig.Combination]) {
		self.layerStrictions = layerStrictions
	}

	public func validItemNameRegex(forLayer layer: String, conditionLayers: [InputData.ImageLayer<some Location>]) -> Regex? {
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
