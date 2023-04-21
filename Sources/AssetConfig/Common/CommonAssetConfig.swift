public protocol CommonAssetConfig {
	associatedtype MetadataType: CommonMetadata

	var metadata: MetadataType { get }
}
