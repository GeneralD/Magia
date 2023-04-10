public protocol Allocation {
	associatedtype SubjectType: Subject

	var target: SubjectType { get }
	var quantity: Int { get }
}
