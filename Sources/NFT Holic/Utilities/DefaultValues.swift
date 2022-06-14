import DefaultCodable
import CoreGraphics

enum ZeroFloat: DefaultValueProvider {
	static var `default`: CGFloat = 0
}

enum OneFloat: DefaultValueProvider {
	static var `default`: CGFloat = 1
}

enum OneDouble: DefaultValueProvider {
	static var `default`: Double = 1
}

enum ZeroFillThreeDigitsFormat: DefaultValueProvider {
	static var `default` = "%03d"
}

enum BlackHexCode: DefaultValueProvider {
	static let `default` = "000000"
}

enum WhiteHexCode: DefaultValueProvider {
	static let `default` = "ffffff"
}

enum RegexMatchesNothing: DefaultValueProvider {
	static var `default` = "^(?!)$"
}

enum FontMidiumSize: DefaultValueProvider {
	static let `default`: CGFloat = 14
}
