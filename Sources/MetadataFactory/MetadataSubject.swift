public enum MetadataSubject {
	case completedAsset(name: String, spells: any Sequence<String>)
	case generativeAssets(layers: any Sequence<LayerSubject>)

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
