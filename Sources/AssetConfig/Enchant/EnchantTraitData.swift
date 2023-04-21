public protocol EnchantTraitData {
	var spell: Regex<AnyRegexOutput> { get }
	var traits: [CommonTrait] { get }
}
