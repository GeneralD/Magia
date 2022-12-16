import AssetConfig
import CollectionKit
import Files

public struct SingleAssetSequence {
	public let elements: any Sequence<File>

	public init(assetFiles: [File], election: SingleAssetElection, quantity: Int? = nil) throws {
		switch election {
		case .alphabetical:
			let sorted = assetFiles.sorted(at: \.name, by: <)
			guard let quantity else {
				self.elements = sorted
				return
			}
			guard quantity <= sorted.count else {
				throw SingleAssetSequenceError.tooMuchQuantitySpecified
			}
			self.elements = sorted.prefix(quantity)
		case .shuffle(.duplicatable):
			guard let quantity else {
				throw SingleAssetSequenceError.quantityMustBeSpecified
			}
			self.elements = (0..<quantity).compactMap { _ in assetFiles.randomElement() }
		case .shuffle(.unique):
			let shuffled = assetFiles.shuffled()
			guard let quantity else {
				self.elements = shuffled
				return
			}
			guard quantity <= shuffled.count else {
				throw SingleAssetSequenceError.tooMuchQuantitySpecified
			}
			self.elements = shuffled.prefix(quantity)
		}
	}
}
