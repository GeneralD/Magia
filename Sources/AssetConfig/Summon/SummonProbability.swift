public protocol SummonProbability {
	associatedtype SubjectType: CommonSubject

	var target: SubjectType { get }
	var weight: Double { get }
	var divideByMatches: Bool { get }
}
