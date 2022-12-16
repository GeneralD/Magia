public protocol AssetConfig {
	associatedtype OrderType: Order
	associatedtype CombinationType: Combination
	associatedtype RandomizationType: Randomization
	associatedtype DrawSerialType: DrawSerial
	associatedtype MetadataType: Metadata

	var order: OrderType { get }
	var combinations: [CombinationType] { get }
	var randomization: RandomizationType { get }
	var drawSerial: DrawSerialType { get }
	var metadata: MetadataType { get }
	// refered in enchant command
	var singleAsset: SingleAssetElection { get }
}
