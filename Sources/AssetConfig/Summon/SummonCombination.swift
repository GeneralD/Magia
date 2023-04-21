public protocol SummonCombination {
	associatedtype SubjectType: CommonSubject

	var target: SubjectType { get }
	var dependencies: [SubjectType] { get }
}
