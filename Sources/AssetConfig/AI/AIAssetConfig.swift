public protocol AIAssetConfig {
	associatedtype MetadataType: AIMetadata

	var metadata: MetadataType { get }
	var singleAsset: SingleAssetElection { get }
}
