public protocol AIMetadata {
	associatedtype AITraitDataType: AITraitData
	associatedtype AITraitListingType: AITraitListing

	var aiTraitData: [AITraitDataType] { get }
	var aiTraitListing: AITraitListingType { get }
}
