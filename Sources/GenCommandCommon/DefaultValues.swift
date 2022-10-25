import DefaultCodable
import CoreGraphics

public enum ZeroFloat: DefaultValueProvider {
	static public let `default`: CGFloat = 0
}

public enum OneFloat: DefaultValueProvider {
	static public let `default`: CGFloat = 1
}

public enum OneDouble: DefaultValueProvider {
	static public let `default`: Double = 1
}

public enum ZeroFillThreeDigitsFormat: DefaultValueProvider {
	static public let `default` = "%03d"
}

public enum BlackHexCode: DefaultValueProvider {
	static public let `default` = "000000"
}

public enum WhiteHexCode: DefaultValueProvider {
	static public let `default` = "ffffff"
}

public enum RegexMatchesNothing: DefaultValueProvider {
	static public let `default` = "^(?!)$"
}

public enum FontMidiumSize: DefaultValueProvider {
	static public let `default`: CGFloat = 14
}
