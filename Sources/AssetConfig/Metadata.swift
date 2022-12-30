import Foundation

public protocol Metadata {
	associatedtype TraitDataType: TraitData
	associatedtype AITraitDataType: AITraitData

	var baseUrl: URL { get }
	var nameFormat: String { get }
	var descriptionFormat: String { get }
	var externalUrlFormat: String? { get }
	var backgroundColor: String { get }
	var data: [TraitDataType] { get }
	var traitOrder: [String] { get }

	// refered in enchant command
	var aiData: [AITraitDataType] { get }
}
