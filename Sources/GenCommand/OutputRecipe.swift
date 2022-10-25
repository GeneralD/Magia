import GenCommandCommon
import GRDB
import Foundation
import Files

class OutputRecipe: FetchableRecord {
	var id: Int64
	var json: String

	enum Columns: String, ColumnExpression {
		case id, json
	}

	required init(row: Row) {
		id = row[Columns.id]
		json = row[Columns.json]
	}

	required init(id: Int64, json: String) {
		self.id = id
		self.json = json
	}
}

extension OutputRecipe: TableRecord {
	static var databaseTableName: String { "recipe" }

	static func createTable(in db: Database) throws {
		try db.create(table: databaseTableName, ifNotExists: true) { table in
			table.column("id", .integer).primaryKey(onConflict: .replace, autoincrement: false)
			table.column("json", .text).notNull()
		}
	}
}

extension OutputRecipe: PersistableRecord {
	func encode(to container: inout PersistenceContainer) {
		container[Columns.id] = id
		container[Columns.json] = json
	}
}

extension OutputRecipe: Identifiable {}

extension OutputRecipe {
	private struct Layer: Codable {
		let path: String
		let layer: String
		let name: String
		let probability: Double

		static func from<F: Location>(source: InputData.ImageLayer<F>, filePathRelatedTo folder: Folder) -> Self {
			.init(path: source.imageLocation.path(relativeTo: folder), layer: source.layer, name: source.name, probability: source.probability)
		}

		func source<F: Location>(filePathRelatedTo folder: Folder) throws -> InputData.ImageLayer<F> {
			try .init(imageLocation: .init(path: "\(folder.path)\(path)"), layer: layer, name: name, probability: probability)
		}
	}

	convenience init(serial: Int, source: InputData, inputFolder: Folder) {
		let json: String
		switch source.assets {
		case let .animated(layers, _):
			let data = try? JSONEncoder().encode(layers.map { Layer.from(source: $0, filePathRelatedTo: inputFolder) })
			json = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
		case let .still(layers):
			let data = try? JSONEncoder().encode(layers.map { Layer.from(source: $0, filePathRelatedTo: inputFolder) })
			json = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
		}
		self.init(id: Int64(serial), json: json)
	}

	func assets(isAnimated: Bool, animationDuration: Double, inputFolder: Folder) -> InputData.Assets? {
		guard let data = json.data(using: .utf8),
			  let layers = try? JSONDecoder().decode([Layer].self, from: data) else { return nil }

		return isAnimated
		? try? .animated(layers: layers.map({ try $0.source(filePathRelatedTo: inputFolder) }), duration: animationDuration)
		: try? .still(layers: layers.map({ try $0.source(filePathRelatedTo: inputFolder) }))
	}
}
