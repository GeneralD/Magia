public protocol Subject {
	var layer: String { get }
	var name: Regex<AnyRegexOutput> { get }
}
