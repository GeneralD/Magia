public protocol AITraitListing {
	var intent: AITraitListingIntent { get }
	var list: [Regex<AnyRegexOutput>] { get }
}
