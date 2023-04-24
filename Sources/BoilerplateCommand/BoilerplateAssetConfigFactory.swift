import Files

struct BoilerplateAssetConfigFactory {
	private let assetFolder: Folder

	init(assetFolder: Folder) {
		self.assetFolder = assetFolder
	}
}

extension BoilerplateAssetConfigFactory {
	func generate() throws -> BoilerplateAssetConfig {
		let layerFolders = assetFolder.subfolders.filter { !$0.isEmpty() }
		let layerNames = layerFolders.map(\.name).sorted(by: <)

		let combinations = try layerFolders
			.flatMap { layerFolder in
				let names = layerFolder.files.map(\.nameExcludingExtension) + layerFolder.subfolders.map(\.name)
				return try names
					.map { BoilerplateAssetConfig.BoilerplateCombination(target: try .init(layerExpression: layerFolder.name, nameExpression: "^\($0)$"), dependencies: []) }
			}

		let probabilities = try layerFolders
			.flatMap { layerFolder in
				let names = layerFolder.files.map(\.nameExcludingExtension) + layerFolder.subfolders.map(\.name)
				return try names
					.map { try BoilerplateAssetConfig.BoilerplateSubject(layerExpression: layerFolder.name, nameExpression: "^\($0)$") }
					.map { BoilerplateAssetConfig.BoilerplateRandomization.BoilerplateProbability(target: $0, weight: 1, divideByMatches: false) }
			}

		let traits = try layerFolders
			.flatMap { layerFolder in
				let names = layerFolder.files.map(\.nameExcludingExtension) + layerFolder.subfolders.map(\.name)
				return try names
					.map {
						BoilerplateAssetConfig.BoilerplateMetadata.BoilerplateTraitData(
							traits: [.label(trait: layerFolder.name, value: .string($0))],
							conditions: [try .init(layerExpression: layerFolder.name, nameExpression: "^\($0)$")])
					}
			}

		return .init(
			order: .init(
				selection: layerNames,
				layerDepth: layerNames),
			combinations: combinations,
			randomization: .init(
				probabilities: probabilities,
				allocations: []),
			drawSerial: .init(
				enabled: false,
				format: "#%05d",
				font: "Helvetica",
				size: 38,
				color: "ffffff",
				offsetX: 40,
				offsetY: 15),
			metadata: .init(
				baseUrl: .init(string: "https://example.com/") ?? .init(filePath: ""),
				nameFormat: "Magia NFT %05d",
				descriptionFormat: "This NFT is generated by Magia.  \nMagia is an ultimate NFT generator for the proffesional creators.",
				externalUrlFormat: "https://example_frontend.com/nfts/%05d",
				backgroundColor: "000000",
				traitData: traits,
				traitOrder: layerNames))
	}
}
