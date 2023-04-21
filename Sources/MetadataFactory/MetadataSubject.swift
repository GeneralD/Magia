import protocol AssetConfig.AIMetadata
import protocol AssetConfig.Metadata

public enum MetadataSubject {
	case completedAsset(name: String, spells: any Sequence<String>, config: any AssetConfig.Metadata & AssetConfig.AIMetadata)
	case generativeAssets(layers: any Sequence<LayerSubject>, config: any AssetConfig.Metadata)

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
	var config: any AssetConfig.Metadata {
		switch self {
			case .completedAsset(_, _, let config):
				return config
			case .generativeAssets(_, let config):
				return config
		}
	}
}
