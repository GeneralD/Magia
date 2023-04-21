import Foundation

public enum CommonTrait: Equatable {
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
