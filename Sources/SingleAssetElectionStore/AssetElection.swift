import GRDB
import Foundation

class AssetElection: FetchableRecord {
	var id: Int64
	var path: String

	enum Columns: String, ColumnExpression {
		case id, path
	}

	required init(row: Row) {
		id = row[Columns.id]
		path = row[Columns.path]
	}

	required init(id: Int64, path: String) {
		self.id = id
		self.path = path
	}
}

extension AssetElection: TableRecord {
	static var databaseTableName: String { "election" }

	static func createTable(in db: Database) throws {
		try db.create(table: databaseTableName, ifNotExists: true) { table in
			table.column("id", .integer).primaryKey(onConflict: .replace, autoincrement: false)
			table.column("path", .text).notNull()
		}
	}
}

extension AssetElection: PersistableRecord {
	func encode(to container: inout PersistenceContainer) {
		container[Columns.id] = id
		container[Columns.path] = path
	}
}

extension AssetElection: Identifiable {}
