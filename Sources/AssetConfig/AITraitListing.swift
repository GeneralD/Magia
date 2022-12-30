public enum AITraitListing: Equatable, Codable {
	case allow(list: [String])
	case block(list: [String])
}
