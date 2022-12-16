public protocol Randomization {
	associatedtype ProbabilityType: Probability

	var probabilities: [ProbabilityType] { get }
}
