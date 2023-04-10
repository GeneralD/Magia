public protocol Reservation {
	associatedtype AllocationType: Allocation
	var layer: String { get }
	var quantity: Int { get }
	var allocations: [AllocationType] { get }
}
