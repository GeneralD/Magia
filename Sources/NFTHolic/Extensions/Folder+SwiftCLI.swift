import Files
import Foundation
import SwiftCLI

extension Folder: ConvertibleFromString {
	public init?(input: String) {
		let fileManager = FileManager.default
		var isDir: ObjCBool = false
		let dirExists = fileManager.fileExists(atPath: input, isDirectory: &isDir) && isDir.boolValue
		if !dirExists {
			try? fileManager.createDirectory(at: .init(fileURLWithPath: input), withIntermediateDirectories: true)
		}
		try? self.init(path: input)
	}
}
