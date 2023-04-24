import AssetConfig

public struct LayerConstraintFactory {

	private let layerStrictions: any Sequence<any SummonCombination>

	public init(layerStrictions: any Sequence<any SummonCombination>) {
		self.layerStrictions = layerStrictions
	}

	public func constraint(forLayer layer: String, conditionLayers: some Sequence<LayerConstraintSubject>) -> LayerConstraint {
		let dependencies = conditionLayers
		// pick up all related strictions with current layer selections
			.flatMap { conditionLayer in
				layerStrictions.filter { combination in
					conditionLayer.layer.contains(combination.target.layer) && conditionLayer.name.contains(combination.target.name)
				}
			}
			.flatMap { $0.dependencies } // keypath \.dependencies triggers a fatal error at runtime by compiler bug
			.filter { dependency in layer.contains(dependency.layer) }
		return .init(subjects: dependencies)
	}
}
