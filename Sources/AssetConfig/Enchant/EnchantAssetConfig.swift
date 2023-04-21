public protocol EnchantAssetConfig: CommonAssetConfig where MetadataType: EnchantMetadata {
	var metadata: MetadataType { get }
	var singleAsset: EnchantSingleAssetElection { get }
}
