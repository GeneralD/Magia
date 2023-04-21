import SummonCommandCommon
import MetadataFactory
import protocol AssetConfig.Metadata

extension InputData.Assets {
	func metadataSubject(config: any AssetConfig.Metadata) -> MetadataSubject {
		switch self {
			case let .animated(layers, _):
				return .generativeAssets(layers: layers.map(\.metadataLayerSubject), config: config)
			case let .still(layers):
				return .generativeAssets(layers: layers.map(\.metadataLayerSubject), config: config)
		}
	}
}
