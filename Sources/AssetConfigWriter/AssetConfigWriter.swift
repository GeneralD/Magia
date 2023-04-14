import Files
import Foundation
import Yams

public struct AssetConfigWriter {
	private let format: AssetConfigWritingFormat

	public init(format: AssetConfigWritingFormat = .yaml) {
		self.format = format
	}
}

public extension AssetConfigWriter {
	func write(config: some Encodable, in folder: Folder, overwrite: Bool = false) -> Result<File, AssetConfigWriterError> {
		guard overwrite || !folder.containsFile(named: configFileName) else { return .failure(.fileExists) }

		let file: File
		do {
			file = try folder.createFileIfNeeded(withName: configFileName)
		} catch {
			return .failure(.creatingFileFailed)
		}

		do {
			switch format {
				case .yaml:
					try file.write(YAMLEncoder().encode(config))
				case .json:
					try file.write(JSONEncoder().encode(config))
			}
		} catch {
			return .failure(.writingDataFailed)
		}

		return .success(file)
	}
}

private extension AssetConfigWriter {
	var configFileName: String {
		switch format {
			case .yaml:
				return "config.yml"
			case .json:
				return "config.json"
		}
	}
}

public enum AssetConfigWriterError: Error {
	case fileExists
	case creatingFileFailed
	case writingDataFailed
}

public enum AssetConfigWritingFormat {
	case yaml, json
}
