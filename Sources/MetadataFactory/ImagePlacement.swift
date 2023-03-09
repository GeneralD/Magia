import Foundation

public enum ImagePlacement {
	case asFileOnServer(folderName: String)
	case encodedInMetadata(data: Data)
}
