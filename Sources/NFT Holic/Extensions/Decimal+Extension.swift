import Foundation

extension Decimal {
	init(_ value: Double, digitsAfterPoint: Int) {
		self = .init(string: .init(format: "%.\(digitsAfterPoint)f", value)) ?? .init(value)
	}

	init(_ value: Float, digitsAfterPoint: Int) {
		self = .init(string: .init(format: "%.\(digitsAfterPoint)f", value)) ?? .init(Double(value))
	}
}
