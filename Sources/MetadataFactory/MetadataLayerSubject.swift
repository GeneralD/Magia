public struct MetadataLayerSubject {
	let layer: String
	let name: String
	let probability: Double

	public init(layer: String, name: String, probability: Double) {
		self.layer = layer
		self.name = name
		self.probability = probability
	}
}
