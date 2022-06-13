import Foundation

@propertyWrapper
public struct Atomic<ValueType> {
	private let lock = NSLock()
	private let queue = DispatchQueue(label: "atomicProperty:\(UUID().uuidString)")
	private var value: ValueType

	public init(wrappedValue: ValueType) {
		value = wrappedValue
	}

	public var wrappedValue: ValueType {
		get {
			lock.lock()
			defer { lock.unlock() }
			return queue.sync { value }
		}
		set {
			lock.lock()
			defer { lock.unlock() }
			queue.sync { value = newValue }
		}
	}
}
