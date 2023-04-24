import AssetConfig

public struct LayerConstraintFactory {

	private let layerStrictions: any Sequence<any SummonCombination>
	private let specials: any Sequence<any SummonSpecial>

	public init(layerStrictions: any Sequence<any SummonCombination>, specials: any Sequence<any SummonSpecial>) {
		self.layerStrictions = layerStrictions
		self.specials = specials
	}

	public func constraint(forIndex index: Int, forLayer layer: String, conditionLayers: some Sequence<LayerConstraintSubject>) -> LayerConstraint {
		let layerDependencies = conditionLayers
		// pick up all related strictions with current layer selections
			.flatMap { conditionLayer in
				layerStrictions.filter { combination in
					conditionLayer.layer.contains(combination.target.layer) && conditionLayer.name.contains(combination.target.name)
				}
			}
			.flatMap { $0.dependencies } // keypath \.dependencies triggers a fatal error at runtime by compiler bug

		let indexDependencies = specials
			.filter { $0.index == index }
			.flatMap { $0.dependencies } // keypath \.dependencies triggers a fatal error at runtime by compiler bug

		let dependencies = (layerDependencies + indexDependencies)
			.filter { dependency in layer.contains(dependency.layer) }

		return .init(subjects: dependencies)
	}
}
