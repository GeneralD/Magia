import AssetConfig
import CollectionKit
import Files

public struct SingleAssetSequence {
	private let elements: [File]

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
			self.elements = sorted.prefix(quantity).array
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
			self.elements = shuffled.prefix(quantity).array
		}
	}
}

extension SingleAssetSequence: Collection {
	public func index(after i: Int) -> Int {
		elements.index(after: i)
	}

	public var startIndex: Int {
		elements.startIndex
	}

	public var endIndex: Int {
		elements.endIndex
	}

	public subscript(position: Int) -> File {
		elements[position]
	}
}
