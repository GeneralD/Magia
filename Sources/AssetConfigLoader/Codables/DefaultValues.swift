import DefaultCodable
import Foundation

enum ZeroFloat: DefaultValueProvider {
	public static let `default`: CGFloat = 0
}

enum OneFloat: DefaultValueProvider {
	public static let `default`: CGFloat = 1
}

enum OneDouble: DefaultValueProvider {
	public static let `default`: Double = 1
}

enum ZeroFillThreeDigitsFormat: DefaultValueProvider {
	public static let `default` = "%03d"
}

enum BlackHexCode: DefaultValueProvider {
	public static let `default` = "000000"
}

enum WhiteHexCode: DefaultValueProvider {
	public static let `default` = "ffffff"
}

enum FontMidiumSize: DefaultValueProvider {
	public static let `default`: CGFloat = 14
}

enum BlankURL: DefaultValueProvider {
	public static let `default` = URL(fileURLWithPath: "")
}

enum Nil<T>: DefaultValueProvider where T: Equatable, T: Codable {
	public static var `default`: T? { nil }
}
