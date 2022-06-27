import Files
import Regex

struct RamdomizationController {
	let config: AssetConfig.Randomization

	func elect<F: Location>(from candidates: [F], targetLayer: String) -> (element: F, probability: Double)? where F: Hashable {
		let defaultProbability: Double = 1
		let initDict = candidates.reduce(into: [:]) { accum, candidate in
			accum[candidate] = defaultProbability
		}

		let dict = config.probabilities
			.filter { probability in probability.target.layer == targetLayer }
			.reduce(into: initDict) { accum, probability in
				let matches = candidates.filter { candidate in
					candidate.name =~ probability.target.name
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
