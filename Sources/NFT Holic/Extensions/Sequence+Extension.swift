import CollectionKit

extension Sequence {
	func unique<Identifier: Hashable>(where: (Element) -> Identifier, selector: (Element, Element) -> Element = { $1 }) -> [Element] {
		reduce(into: [:], { accum, element in
			let prev = accum[`where`(element)]
			accum[`where`(element)] = prev.map { selector($0, element) } ?? element
		}).values.array
	}

	func sort<Sample: Sequence, Compared: Hashable>(where: (Element) -> Compared, orderSample: Sample, shouldCover: Bool = true) -> [Element]? where Sample.Element == Compared {
		let result = orderSample.compactMap { sample in
			first { subject in
				`where`(subject) == sample
			}
		}
		guard !shouldCover || array.count == result.count else {
			// something not found in sample
			return nil
		}
		return result
	}
}

extension Optional where Wrapped: Sequence {
	var orEmpty: [Wrapped.Element] {
		self?.array ?? []
	}
}
