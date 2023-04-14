import AssetConfigWriter
import CommandCommon
import Files
import Foundation
import SwiftCLI

public class BoilerplateCommand: Command {

	// MARK: - Arguments

	@Param(completion: .values(BoilerplateSubject.allCases.map { (name: $0.rawValue, description: "Initialize \($0)") }))
	var subject: BoilerplateSubject

	@Param(completion: .filename)
	var inputFolder: Folder

	@Flag("-f", "--overwrite", description: "Overwrite existing files")
	var forceOverwrite: Bool

	// MARK: - Command Implementations

	public let name: String
	public let shortDescription = "Generate a boilerplate"

	public init(name: String) {
		self.name = name
	}

	public func execute() throws {
		generate()
	}
}

private extension BoilerplateCommand {

	// MARK: - Generate

	func generate() {
		switch subject {
			case .config:
				let factory = BoilerplateAssetConfigFactory(assetFolder: inputFolder)
				let config = factory.generate()
				let writer = AssetConfigWriter(format: .yaml)
				switch writer.write(config: config, in: inputFolder, overwrite: forceOverwrite) {
					case .success(let file):
						stdout <<< "A boilerplate has been written to \(file.path)!"
					case .failure(.fileExists):
						stderr <<< "config.yml already exists in \(inputFolder.name)"
					case .failure(.creatingFileFailed):
						stderr <<< "Couldn't create config.yml in \(inputFolder.name)"
					case .failure(.writingDataFailed):
						stderr <<< "Couldn't write data into config.yml"
				}
		}
	}
}
