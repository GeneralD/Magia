import GRDB
import Files

public class SingleAssetElectionStore {
	private let inputDB: DatabaseQueue?
	private let outputDB: DatabaseQueue

	public init(inputDatabaseFile: File?, outputDatabaseFolder: Folder) throws {
		inputDB = try inputDatabaseFile.map { try DatabaseQueue(path: $0.path) }
		outputDB = try DatabaseQueue(path: "\(outputDatabaseFolder.path)/data.sqlite")
		_ = try outputDB.inDatabase(AssetElection.createTable(in:))
	}
}

public extension SingleAssetElectionStore {
	subscript(index: Int, inputFolder: Folder) -> File? {
		get {
			guard let election = try? fetch(by: index) else { return nil }
			return try? inputFolder.file(at: election.path)
		}

		set {
			guard let newValue else { return }
			try? outputDB.inDatabase(AssetElection(id: Int64(index), path: newValue.path(relativeTo: inputFolder)).save)
		}
	}

	func close() throws {
		try inputDB?.close()
		try outputDB.close()
	}
}

private extension SingleAssetElectionStore {
	func fetch(by index: Int) throws -> AssetElection? {
		try inputDB?.inDatabase(AssetElection.filter(id: Int64(index)).fetchOne)
	}
}
