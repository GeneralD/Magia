import Regex
import SwiftCLI

extension Validation where T: Comparable {

	static func greaterThanOrEqual(_ value: T, message: String? = nil) -> Validation {
		.custom(message ?? "must be greater than or equal \(value)") { $0 >= value }
	}

	static func lessThanOrEqual(_ value: T, message: String? = nil) -> Validation {
		.custom(message ?? "must be less than or equal \(value)") { $0 <= value }
	}
}

extension Validation where T == String {

	static func formatInteger(message: String? = nil) -> Validation {
		.custom(message ?? "must include integer format") { $0 =~ "^.*%[\\-\\+0-9]*d.*$".r }
	}
}
