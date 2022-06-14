import DefaultCodable
import CoreGraphics

enum Zero: DefaultValueProvider {
	static var `default`: CGFloat = 0
}

enum ZeroFillThreeDigitsFormat: DefaultValueProvider {
	static var `default` = "%03d"
}

enum BlackHexCode: DefaultValueProvider {
	static let `default` = "000000"
}

enum RegexMatchesNothing: DefaultValueProvider {
	static var `default` = "^(?!)$"
}

enum FontMidiumSize: DefaultValueProvider {
	static let `default`: CGFloat = 14
}
