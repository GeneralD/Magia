public protocol AITraitData {
	associatedtype AITraitSpellConversionType: AITraitSpellConversion
	var conversions: [AITraitSpellConversionType] { get }
	var listing: AITraitListing { get }
}
