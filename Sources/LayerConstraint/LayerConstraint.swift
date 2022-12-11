import AssetConfig

public struct LayerConstraint {
	private let subjects: any Sequence<any Subject>

	init(subjects: any Sequence<any Subject>) {
		self.subjects = subjects
	}

	public func isValidItem(name: String) -> Bool {
		subjects.reduce(true) { accum, subject in accum && name.contains(subject.name) }
	}
}
