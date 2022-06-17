import Foundation

extension NSAttributedString {
	func replaced(text: String) -> Self {
		.init(string: text, attributes: attributes(at: 0, effectiveRange: nil))
	}

	func format(_ arguments: CVarArg...) -> Self {
		replaced(text: .init(format: string, arguments))
	}
}
