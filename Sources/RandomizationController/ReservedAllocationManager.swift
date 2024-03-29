import AssetConfig
import Files

public struct ReservedAllocationManager {
	private var reserved: [CommonSubject] = []

	public init(config: some Sequence<any SummonAllocation>) {
		reserved = config
			.filter { allocation in allocation.quantity > .zero }
			.flatMap { allocation in (0..<allocation.quantity).map { _ in allocation.target } }
			.shuffled()
	}

	public mutating func dealNext<F: Location>(originalCandidates candidates: some Sequence<F>, targetLayer: String) -> any Sequence<F> {
		guard let (index, subject) = reserved.enumerated().first(where: { _, sub in targetLayer.contains(sub.layer) }) else { return candidates }
		defer { reserved.remove(at: index) }
		return candidates.filter( { $0.nameExcludingExtension.contains(subject.name) })
	}
}
