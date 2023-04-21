public protocol CommonSubject {
	var layer: String { get }
	var name: Regex<AnyRegexOutput> { get }
}
