import AssetConfig
import DefaultCodable

extension AITraitListing: DefaultValueProvider {
	public static let `default`: Self = .block(list: [])
}
