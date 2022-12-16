import Foundation

public protocol DrawSerial {
	var enabled: Bool { get }
	var format: String { get }
	var font: String { get }
	var size: CGFloat { get }
	var color: String { get }
	var offsetX: CGFloat { get }
	var offsetY: CGFloat { get }
}
