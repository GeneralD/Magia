import CollectionKit

extension Sequence {
	func unique<Identifier: Hashable>(where: (Element) -> Identifier) -> [Element] {
		reduce(into: [:], { accum, element in
			accum[`where`(element)] = element
		}).values.array
	}
}
