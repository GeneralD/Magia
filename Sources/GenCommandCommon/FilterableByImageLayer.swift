public protocol FilterableByImageLayer {
	associatedtype Element: ImageLayerSubject
	var subjects: [Element] { get }
}

extension Sequence where Element: FilterableByImageLayer {
	public func filtered(by layer: ImageLayerSubject) -> [Element] {
		filter { element in
			element.subjects.contains { subject in
				subject.contains(layer)
			}
		}
	}
}
