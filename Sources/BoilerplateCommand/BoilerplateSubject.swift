import SwiftCLI

enum BoilerplateSubject: String {
	case config
}

extension BoilerplateSubject: ConvertibleFromString {
	init?(input: String) {
		self.init(rawValue: input)
	}
}

extension BoilerplateSubject: CaseIterable {}
