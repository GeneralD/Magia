import CommandCommon
import CollectionKit
import Files
import HashKit
import SwiftCLI
import Foundation

public class CleanCommand: Command {
	public let name = "clean"
	public let shortDescription = "Clean your assets"

	@Param(completion: .filename)
	var inputFolder: Folder

	@Flag("-x", "execute", description: "Execute cleaning")
	var executeCleaning: Bool

	public init() {}

	public func execute() throws {
		defer {
			if !executeCleaning {
				stdout <<< "If you want to delete unneeded files actually, add an option -x"
			}
		}

		let deleted = try inputFolder
			.subfolders
			.flatMap(\.subfolders)
			.flatMap { framesFolder -> [String] in
				let files = framesFolder.files
				switch files.count() {
				case 0:
					stdout <<< "\(framesFolder.name) is empty folder."
					guard executeCleaning else { return [] }
					try framesFolder.delete()
					return [framesFolder.path]
				case 1:
					stdout <<< "No need to clean \(framesFolder.name) folder."
					return []
				case 2...:
					let hashes = try files.compactMap { file in
						try file.read().sha256()
					}
					let set = Set(hashes)
					switch set.count {
					case 1:
						stdout <<< "All files contents in \(framesFolder.name) are same."
						guard executeCleaning else { return [] }
						let files = files.array.sorted(at: \.name, by: <)[1...] // leave first one
						for file in files {
							try file.delete()
						}
						return files.map(\.path)
					case 2...:
						return []
					default:
						assertionFailure("logically unreachable")
						return []
					}
				default:
					assertionFailure("logically unreachable")
					return []
				}
			}

		guard !deleted.isEmpty else { return }

		stdout <<< "Deleted files:"
		stdout <<< deleted.joined(separator: "\n")
		stdout <<< "\(deleted.count) files and folders are deleted."
	}
}
