import GenCommandCommon
import LayerConstraint
import MetadataFactory

extension InputData.ImageLayer {
	var layerConstraintSubject: LayerConstraintSubject {
		.init(layer: layer, name: name)
	}

	var metadataLayerSubject: MetadataLayerSubject {
		.init(layer: layer, name: name, probability: probability)
	}
}
