import GenCommandCommon
import Files
import GRDB

public struct RecipeStore {
	private let inputDB: DatabaseQueue?
	private let outputDB: DatabaseQueue

	public init(inputDatabaseFile: File?, outputDatabaseFolder: Folder) throws {
		inputDB = try inputDatabaseFile.map { try DatabaseQueue(path: $0.path) }
		outputDB = try DatabaseQueue(path: "\(outputDatabaseFolder.path)/data.sqlite")
		_ = try outputDB.inDatabase(OutputRecipe.createTable(in:))
	}
}

public extension RecipeStore {
	func storedAssets(for index: Int, isAnimated: Bool, animationDuration: Double, inputFolder: Folder) throws -> InputData.Assets? {
		try fetch(by: index)?.assets(isAnimated: isAnimated, animationDuration: animationDuration, inputFolder: inputFolder)
	}

	func storeAssets(for index: Int, source: InputData, inputFolder: Folder) throws {
		try outputDB.inDatabase(OutputRecipe(serial: index, source: source, inputFolder: inputFolder).save)
	}

	func close() throws {
		try inputDB?.close()
		try outputDB.close()
	}
}

private extension RecipeStore {
	func fetch(by index: Int) throws -> OutputRecipe? {
		try inputDB?.inDatabase(OutputRecipe.filter(id: Int64(index)).fetchOne)
	}
}
