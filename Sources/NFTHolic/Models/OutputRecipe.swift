import GRDB
import Foundation
import Files

class OutputRecipe: FetchableRecord {
	var id: Int64
	var json: String

	required init(row: Row) {
		id = row["id"]
		json = row["json"]
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
		container["id"] = id
		container["json"] = json
	}
}

extension OutputRecipe {
	private struct Layer: Encodable {
		let layer: String
		let name: String
		let probability: Double
	}

	convenience init(serial: Int, source: InputData) {
		let json: String
		switch source.assets {
		case let .animated(layers, _):
			let data = try? JSONEncoder().encode(layers.map { Layer(layer: $0.layer, name: $0.name, probability: $0.probability) })
			json = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
		case let .still(layers):
			let data = try? JSONEncoder().encode(layers.map { Layer(layer: $0.layer, name: $0.name, probability: $0.probability) })
			json = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
		}
		self.init(id: Int64(serial), json: json)
	}
}
