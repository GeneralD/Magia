import AssetConfig
import SummonCommandCommon
import MetadataFactory

extension InputData.Assets {
	func metadataSubject(config: any CommonMetadata) -> MetadataSubject {
		switch self {
			case let .animated(layers, _):
				return .generativeAssets(layers: layers.map(\.metadataLayerSubject), config: config)
			case let .still(layers):
				return .generativeAssets(layers: layers.map(\.metadataLayerSubject), config: config)
		}
	}
}
