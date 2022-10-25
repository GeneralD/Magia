import SwiftCLI
import UniformTypeIdentifiers

extension UTType: ConvertibleFromString {
	public init?(input: String) {
		switch input {
		case "gif":
			self = .gif
		case "png":
			self = .png
		default:
			return nil
		}
	}
}
