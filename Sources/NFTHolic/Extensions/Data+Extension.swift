import Foundation

extension Data {
	var hexDescription: String {
		map { String(format: "%02x", $0) }.reduce(into: "", +=)
	}
}
