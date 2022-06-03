import Files
import SwiftCLI

extension Folder: ConvertibleFromString {
	public init?(input: String) {
		try? self.init(path: input)
	}
}
