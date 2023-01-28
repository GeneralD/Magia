import CollectionKit

extension Dictionary where Value == Double {
	func weightedRandom() -> (element: Key, probability: Double)? {
		let totalWeight = values.reduce(into: .zero, +=)
		guard totalWeight > .zero else { return first.map { ($0.key, .zero) }}
		let dict = reduce(into: [Key: Range<Value>]()) { accum, pair in
			let start = accum.values.map(\.upperBound).max ?? .zero
			accum[pair.key] = start..<(start + pair.value)
		}
		guard let max = dict.values.map(\.upperBound).max else { return nil }
		let rand = Double.random(in: .zero..<max)
		guard let selected = dict.first(where: { pair in pair.value.contains(rand) }) else { return nil }
		let weight = self[selected.key] ?? .zero
		return (selected.key, weight / totalWeight)
	}
}
