public protocol EnchantTraitListing {
	var intent: EnchantTraitListingIntent { get }
	var list: [Regex<AnyRegexOutput>] { get }
}
