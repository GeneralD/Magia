import CollectionKit
import Foundation

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

	func waitAll<Result>(queueLabelPrefix: String, qos: Dispatch.DispatchQoS = .utility, operation: @escaping (Element) -> Result) -> [Element: Result] where Element: Hashable {
		@Locked var accumulator = [Element: Result]()
		let group = DispatchGroup()
		for element in self {
			group.enter()
			let dispatch = DispatchQueue(label: "\(queueLabelPrefix).\(element.hashValue)", qos: qos)
			dispatch.async(group: group) {
				defer { group.leave() }
				accumulator[element] = operation(element)
			}
		}
		group.wait()
		return accumulator
	}
}
