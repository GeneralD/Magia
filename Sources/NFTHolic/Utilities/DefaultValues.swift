import DefaultCodable
import CoreGraphics

enum ZeroFloat: DefaultValueProvider {
	static let `default`: CGFloat = 0
}

enum OneFloat: DefaultValueProvider {
	static let `default`: CGFloat = 1
}

enum OneDouble: DefaultValueProvider {
	static let `default`: Double = 1
}

enum ZeroFillThreeDigitsFormat: DefaultValueProvider {
	static let `default` = "%03d"
}

enum BlackHexCode: DefaultValueProvider {
	static let `default` = "000000"
}

enum WhiteHexCode: DefaultValueProvider {
	static let `default` = "ffffff"
}

enum RegexMatchesNothing: DefaultValueProvider {
	static let `default` = "^(?!)$"
}

enum FontMidiumSize: DefaultValueProvider {
	static let `default`: CGFloat = 14
}
