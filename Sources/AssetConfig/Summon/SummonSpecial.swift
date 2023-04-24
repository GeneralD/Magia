public protocol SummonSpecial {
	associatedtype SubjectType: CommonSubject

	var index: Int { get }
	var dependencies: [SubjectType] { get }
}
