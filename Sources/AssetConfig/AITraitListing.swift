public enum AITraitListing: Equatable, Codable {
	case allow(spells: [String])
	case block(spells: [String])
}
