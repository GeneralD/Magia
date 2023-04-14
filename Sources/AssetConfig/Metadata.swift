import Foundation

public protocol Metadata {
	associatedtype TraitDataType: TraitData

	var baseUrl: URL { get }
	var nameFormat: String { get }
	var descriptionFormat: String { get }
	var externalUrlFormat: String? { get }
	var backgroundColor: String { get }
	var traitData: [TraitDataType] { get }
	var traitOrder: [String] { get }
}
