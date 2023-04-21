public protocol EnchantMetadata: CommonMetadata {
	associatedtype EnchantTraitDataType: EnchantTraitData
	associatedtype EnchantTraitListingType: EnchantTraitListing

	var aiTraitData: [EnchantTraitDataType] { get }
	var aiTraitListing: EnchantTraitListingType { get }
}
