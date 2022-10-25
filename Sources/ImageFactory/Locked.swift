import Foundation

@propertyWrapper
struct Locked<ValueType> {
	private let lock = NSLock()
	private var value: ValueType

	init(wrappedValue: ValueType) {
		value = wrappedValue
	}

	var wrappedValue: ValueType {
		get {
			lock.lock()
			defer { lock.unlock() }
			return value
		}
		set {
			lock.lock()
			defer { lock.unlock() }
			value = newValue
		}
	}
}
