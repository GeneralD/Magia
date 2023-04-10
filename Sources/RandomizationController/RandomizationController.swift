import AssetConfig
import CollectionKit
import Files

public struct RandomizationController {
	private let config: any Randomization
	private let reservedWeight: [String: Double]
	private var reserved: [String] = []

	public init(config: some Randomization) {
		self.config = config

		guard let reservation = config.reservation else {
			reservedWeight = [:]
			return
		}

		let totalWeight = reservation.allocations
			.map(\.weight)
			.reduce(.zero, +)

		guard totalWeight > .zero else {
			reservedWeight = [:]
			return
		}

		reservedWeight = reservation.allocations
			.reduce(into: [:]) { accum, alloc in accum[alloc.name] = alloc.weight / totalWeight }

		reserved = reservedWeight
			.mapValues { w in Int(Double(reservation.quantity) * w)	}
			.reduce(into: []) { accum, pair in accum.append(contentsOf: (0..<pair.value).map { _ in pair.key }) }
			.shuffled()

		// supply a shortage
		let shortage = reservation.quantity - reserved.count
		guard shortage > .zero else { return }
		reserved.append(contentsOf: (0..<shortage).compactMap { _ in reservation.allocations.randomElement()?.name })
	}
}

public extension RandomizationController {
	mutating func elect<F: Location>(from candidates: [F], targetLayer: String) -> (element: F, probability: Double)? where F: Hashable {
		guard targetLayer != config.reservation?.layer || reserved.isEmpty else {
			guard let (head, tail) = reserved.splat,
				  let candidate = candidates.first(where: { $0.nameExcludingExtension == head }),
				  let weight = reservedWeight[head] else { return nil }
			reserved = tail.array
			return (candidate, weight)
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
