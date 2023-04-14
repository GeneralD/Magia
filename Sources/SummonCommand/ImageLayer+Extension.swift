import SummonCommandCommon
import LayerConstraint
import MetadataFactory

extension InputData.ImageLayer {
	var layerConstraintSubject: LayerConstraintSubject {
		.init(layer: layer, name: name)
	}

	var metadataLayerSubject: MetadataSubject.LayerSubject {
		.init(layer: layer, name: name, probability: probability)
	}
}
