public protocol Randomization {
	associatedtype ProbabilityType: Probability
	associatedtype AllocationType: Allocation

	var probabilities: [ProbabilityType] { get }
	var allocations: [AllocationType] { get }
}
