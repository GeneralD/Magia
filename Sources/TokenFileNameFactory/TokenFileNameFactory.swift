import SwiftKeccak

public struct TokenFileNameFactory {
	private let nameFormat: String
	private let hash: Bool

	public init(nameFormat: String, hash: Bool) {
		self.nameFormat = nameFormat
		self.hash = hash
	}
}

public extension TokenFileNameFactory {
	func fileName(from index: Int) -> String {
		let fileName = String(format: nameFormat, index)
		guard hash else { return fileName }
		return fileName.keccak().hexDescription
	}
}
