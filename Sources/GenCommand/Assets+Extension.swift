import GenCommandCommon
import MetadataFactory

extension InputData.Assets {
	var metadataLayerSubjects: [MetadataLayerSubject] {
		switch self {
		case let .animated(layers, _):
			return layers.map(\.metadataLayerSubject)
		case let .still(layers):
			return layers.map(\.metadataLayerSubject)
		}
	}
}
