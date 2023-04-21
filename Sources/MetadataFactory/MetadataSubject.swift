import AssetConfig

public enum MetadataSubject {
	case completedAsset(name: String, spells: any Sequence<String>, config: any EnchantMetadata)
	case generativeAssets(layers: any Sequence<LayerSubject>, config: any CommonMetadata)

	public struct LayerSubject {
		let layer: String
		let name: String
		let probability: Double

		public init(layer: String, name: String, probability: Double) {
			self.layer = layer
			self.name = name
			self.probability = probability
		}
	}
}

extension MetadataSubject {
	var config: any CommonMetadata {
		switch self {
			case .completedAsset(_, _, let config):
				return config
			case .generativeAssets(_, let config):
				return config
		}
	}
}
