public protocol SummonAllocation {
	associatedtype SubjectType: CommonSubject

	var target: SubjectType { get }
	var quantity: Int { get }
}
