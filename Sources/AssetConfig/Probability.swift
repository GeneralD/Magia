public protocol Probability {
	associatedtype SubjectType: Subject

	var target: SubjectType { get }
	var weight: Double { get }
	var divideByMatches: Bool { get }
}
