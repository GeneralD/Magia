public protocol TraitData {
	associatedtype SubjectType: Subject

	var traits: [Trait] { get }
	var conditions: [SubjectType] { get }
}
