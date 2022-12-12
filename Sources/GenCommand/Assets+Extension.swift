import GenCommandCommon
import MetadataFactory

extension InputData.Assets {
	var metadataSubject: MetadataSubject {
		switch self {
		case let .animated(layers, _):
			return .generativeAssets(layers: layers.map(\.metadataLayerSubject))
		case let .still(layers):
			return .generativeAssets(layers: layers.map(\.metadataLayerSubject))
		}
	}
}
