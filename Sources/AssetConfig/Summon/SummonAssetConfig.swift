public protocol SummonAssetConfig: CommonAssetConfig where MetadataType: CommonMetadata {
	associatedtype OrderType: SummonOrder
	associatedtype CombinationType: SummonCombination
	associatedtype SpecialType: SummonSpecial
	associatedtype RandomizationType: SummonRandomization
	associatedtype DrawSerialType: SummonDrawSerial

	var order: OrderType { get }
	var combinations: [CombinationType] { get }
	var specials: [SpecialType] { get }
	var randomization: RandomizationType { get }
	var drawSerial: DrawSerialType { get }
	var metadata: MetadataType { get }
}
