extension Dictionary where Value == Double {
	func weightedRandom() -> (element: Key, probability: Double)? {
		guard values.reduce(0, +) > 0 else { return first.map { ($0.key, 0) }}
		let dict = reduce(into: [Key: Range<Value>]()) { accum, pair in
			let start = accum.values.map(\.upperBound).max ?? 0
			accum[pair.key] = start..<(start + pair.value)
		}
		guard let max = dict.values.map(\.upperBound).max else { return nil }
		let rand = Double.random(in: 0..<max)
		guard let selected = dict.first(where: { pair in pair.value.contains(rand) }) else { return nil }
		return (selected.key, self[selected.key]! / values.reduce(into: 0, +=))
	}
}
