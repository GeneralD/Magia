public protocol AITraitTagConversion {
	var tag: Regex<AnyRegexOutput> { get }
	var traits: [Trait] { get }
}
