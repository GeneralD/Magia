public protocol AITraitData {
	var spell: Regex<AnyRegexOutput> { get }
	var traits: [Trait] { get }
}
