import Files
import Regex

struct RamdomizationController {
	let config: AssetConfig.Randomization?

	func elect(from candidates: [Folder], targetLayer: String) -> (element: Folder, probability: Double)? {
		guard let probabilities = config?.probabilities else {
			guard let element = candidates.randomElement() else { return nil }
			return (element, 1 / Double(candidates.count))
		}

		let defaultProbability: Double = 1
		let initDict = candidates.reduce(into: [:]) { accum, candidate in
			accum[candidate] = defaultProbability
		}

		let dict = probabilities
			.filter { probability in probability.target.layer == targetLayer }
			.reduce(into: initDict) { accum, probability in
				let matches = candidates.filter { candidate in
					candidate.name =~ probability.target.name
				}
				let weight = probability.divideByMatches == true
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
