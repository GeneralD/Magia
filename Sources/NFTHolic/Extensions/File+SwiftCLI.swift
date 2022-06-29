import Files
import SwiftCLI

extension File: ConvertibleFromString {
	public init?(input: String) {
		try? self.init(path: input)
	}
}
