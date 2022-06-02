import Files
import SwiftCLI

extension Folder: ConvertibleFromString {
	public init?(input: String) {
		self = try! Folder(path: input)
	}
}
