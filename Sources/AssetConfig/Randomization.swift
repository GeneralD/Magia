public protocol Randomization {
	associatedtype ProbabilityType: Probability
	associatedtype ReservationType: Reservation

	var probabilities: [ProbabilityType] { get }
	var reservation: ReservationType? { get }
}
