public protocol SummonRandomization {
	associatedtype ProbabilityType: SummonProbability
	associatedtype AllocationType: SummonAllocation

	var probabilities: [ProbabilityType] { get }
	var allocations: [AllocationType] { get }
}
