public enum MetadataFactoryError: Error {
	case creatingFileFailed
	case imageUrlFormatIsRequired
	case invalidMetadataSortConfig
	case invalidBackgroundColorCode
	case writingFileFailed
}
