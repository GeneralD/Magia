import RegexBuilder
import SwiftCLI

public extension Validation where T: Comparable {
	static func greaterThanOrEqual(_ value: T, message: String? = nil) -> Validation {
		.custom(message ?? "must be greater than or equal \(value)") { $0 >= value }
	}

	static func lessThanOrEqual(_ value: T, message: String? = nil) -> Validation {
		.custom(message ?? "must be less than or equal \(value)") { $0 <= value }
	}
}

public extension Validation where T: BidirectionalCollection, T.SubSequence == Substring {
	static func formatInteger(message: String? = nil) -> Validation {
		.custom(message ?? "must include integer format") {
			$0.contains(Regex {
				"%"
				Optionally(ChoiceOf {
					"-"
					"+"
				})
				ZeroOrMore(.digit)
				"d"
			})
		}
	}
}
