import Foundation

@propertyWrapper
public struct Locked<ValueType> {
	private let lock = NSLock()
	private var value: ValueType

	public init(wrappedValue: ValueType) {
		value = wrappedValue
	}

	public var wrappedValue: ValueType {
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
