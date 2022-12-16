public enum SingleAssetElection: Equatable {
	case alphabetical
	case shuffle(_: ShuffleOption)

	public enum ShuffleOption: Equatable {
		case duplicatable
		case unique
	}
}
