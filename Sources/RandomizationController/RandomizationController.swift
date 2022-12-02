import GenCommandCommon
import Files

public struct RandomizationController {
	private let config: any Randomization

	public init(config: some Randomization) {
		self.config = config
	}
}

public extension RandomizationController {
	func elect<F: Location>(from candidates: [F], targetLayer: String) -> (element: F, probability: Double)? where F: Hashable {
		let defaultProbability: Double = 1
		let initDict = candidates.reduce(into: [:]) { accum, candidate in
			accum[candidate] = defaultProbability
		}

		let dict = config.probabilities
			.filter { probability in probability.target.layer == targetLayer }
			.reduce(into: initDict) { accum, probability in
				let matches = candidates.filter { candidate in
					guard let regex = try? Regex(probability.target.name) else { return false }
					return candidate.nameExcludingExtension.contains(regex)
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
