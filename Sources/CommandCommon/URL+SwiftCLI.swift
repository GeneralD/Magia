import Foundation
import SwiftCLI

extension URL: ConvertibleFromString {
	public init?(input: String) {
		self.init(string: input)
	}
}
