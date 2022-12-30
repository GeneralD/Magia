public protocol AITraitData {
	associatedtype AITraitTagConversionType: AITraitTagConversion
	var conversions: [AITraitTagConversionType] { get }
	var listing: AITraitListing { get }
}
