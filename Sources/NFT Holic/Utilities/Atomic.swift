import Foundation

@propertyWrapper
public struct Atomic<ValueType> {
	private let queue = DispatchQueue(label: "atomicProperty:\(UUID().uuidString)")
	private var value: ValueType

	public init(wrappedValue: ValueType) {
		value = wrappedValue
	}

	public var wrappedValue: ValueType {
		get { queue.sync { value } }
		set { queue.sync { value = newValue } }
	}
}
