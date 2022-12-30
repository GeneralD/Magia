public protocol AITraitSpellConversion {
	var spell: Regex<AnyRegexOutput> { get }
	var traits: [Trait] { get }
}
