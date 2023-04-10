import AssetConfig
import Files

public struct RandomizationController {
	private let config: any Randomization
	private var reserved: [Subject] = []

	public init(config: some Randomization) {
		self.config = config

		reserved = config.allocations
			.filter { allocation in allocation.quantity > .zero }
			.flatMap { allocation in (0..<allocation.quantity).map { _ in allocation.target } }
			.shuffled()
	}
}

public extension RandomizationController {
	mutating func elect<F: Location>(from candidates: [F], targetLayer: String) -> (element: F, probability: Double)? where F: Hashable {
		if let (index, subject) = reserved.enumerated().first(where: { _, sub in sub.layer == targetLayer }),
		   let candidate = candidates.first(where: { $0.nameExcludingExtension.contains(subject.name) }) {
			reserved.remove(at: index) // mutate
			return (candidate, 1)
		}

		let defaultProbability: Double = 1
		let initDict = candidates.reduce(into: [:]) { accum, candidate in
			accum[candidate] = defaultProbability
		}

		let dict = config.probabilities
			.filter { probability in probability.target.layer == targetLayer }
			.reduce(into: initDict) { accum, probability in
				let matches = candidates.filter { candidate in
					candidate.nameExcludingExtension.contains(probability.target.name)
				}
				let weight = probability.divideByMatches
				? probability.weight / Double(matches.count)
				: probability.weight

				matches.forEach { candidate in
					let w = accum[candidate] ?? defaultProbability
					accum[candidate] = w * weight
				}
			}
		return dict.weightedRandom()
	}
}

extension Folder: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(url)
	}
}

extension File: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(url)
	}
}
