public protocol Reservation {
	associatedtype AllocationType: Allocation
	var layer: String { get }
	var allocations: [AllocationType] { get }
}
