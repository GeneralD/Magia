import Files
import Foundation
import GenCommandCommon
import Yams

public struct AssetConfigLoader {
	public init() {}
	
	public func loadAssetConfig(from file: File) -> Result<any AssetConfig, AssetConfigLoaderError> {
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

	public var defaultConfig: some AssetConfig {
		AssetConfigCodable.default
	}
}

public enum AssetConfigLoaderError: Error {
	case incompatibleFileExtension
	case invalidConfigFile
}
