public protocol CommonTraitData {
	associatedtype SubjectType: CommonSubject

	var traits: [CommonTrait] { get }
	var conditions: [SubjectType] { get }
}
