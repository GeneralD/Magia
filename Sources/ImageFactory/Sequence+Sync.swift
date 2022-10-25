import Foundation

extension Sequence {
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
