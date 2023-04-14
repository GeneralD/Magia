import AssetConfig
import Files
import Foundation
import Yams

public struct AssetConfigLoader {
	public init() {}
	
	public func load(from file: File) -> Result<any AssetConfig & AIAssetConfig, AssetConfigLoaderError> {
		do {
			switch file.extension {
			case "yml", "yaml":
				return .success(try YAMLDecoder().decode(AssetConfigCodable.self, from: file.read()))
			case "json":
				return .success(try JSONDecoder().decode(AssetConfigCodable.self, from: file.read()))
			default:
				return .failure(.incompatibleFileExtension)
			}
		} catch {
			return .failure(.invalidConfigFile)
		}
	}

	public var defaultConfig: some AssetConfig & AIAssetConfig {
		AssetConfigCodable.default
	}
}

public enum AssetConfigLoaderError: Error {
	case incompatibleFileExtension
	case invalidConfigFile
}
