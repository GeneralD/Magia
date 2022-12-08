import Foundation

public protocol AssetConfig {
	associatedtype OrderType: Order
	associatedtype CombinationType: Combination
	associatedtype RandomizationType: Randomization
	associatedtype DrawSerialType: DrawSerial
	associatedtype MetadataType: Metadata

	var order: OrderType? { get }
	var combinations: [CombinationType] { get }
	var randomization: RandomizationType { get }
	var drawSerial: DrawSerialType { get }
	var metadata: MetadataType? { get }
}

public protocol Order {
	var selection: [String]? { get }
	var layerDepth: [String]? { get }
}

public protocol Combination: FilterableByImageLayer {
	associatedtype SubjectType: Subject

	var target: SubjectType { get }
	var dependencies: [SubjectType] { get }
}

public protocol Randomization {
	associatedtype ProbabilityType: Probability

	var probabilities: [ProbabilityType] { get }
}

public protocol Probability {
	associatedtype SubjectType: Subject

	var target: SubjectType { get }
	var weight: Double { get }
	var divideByMatches: Bool { get }
}

public protocol Subject: ImageLayerSubject {
	var layer: String { get }
	var name: String { get }
}

public protocol DrawSerial {
	var enabled: Bool { get }
	var format: String { get }
	var font: String { get }
	var size: CGFloat { get }
	var color: String { get }
	var offsetX: CGFloat { get }
	var offsetY: CGFloat { get }
}

public protocol Metadata {
	associatedtype TraitDataType: TraitData

	var baseUrl: URL { get }
	var nameFormat: String { get }
	var descriptionFormat: String { get }
	var externalUrlFormat: String? { get }
	var backgroundColor: String { get }
	var data: [TraitDataType] { get }
	var traitOrder: [String] { get }
}

public protocol TraitData: FilterableByImageLayer {
	associatedtype SubjectType: Subject

	var traits: [Trait] { get }
	var conditions: [SubjectType] { get }
}

public enum Trait: Equatable {
	case simple(value: String)
	case label(trait: String, value: LabelValueType)
	case rankedNumber(trait: String, value: Decimal)
	case boostNumber(trait: String, value: Decimal, max: Decimal)
	case boostPercentage(trait: String, value: Decimal)
	case rarityPercentage(trait: String)

	public enum LabelValueType: Equatable, Codable {
		case string(_: String)
		case date(_: Date)
		case number(_: Decimal)
	}
}
