import CoreFoundation

extension Dictionary where Key == String, Value == Any {
	func callAsFunction(key: CFString) -> String? {
		self[key as String] as? String
	}
}
