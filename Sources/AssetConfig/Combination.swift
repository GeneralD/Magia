public protocol Combination {
	associatedtype SubjectType: Subject

	var target: SubjectType { get }
	var dependencies: [SubjectType] { get }
}
