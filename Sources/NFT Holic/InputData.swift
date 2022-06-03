import AppKit
import CollectionKit
import Files

struct InputData {
	let layers: [ImageLayer]
	let animationDuration: Double
	let serialText: SerialText?

	struct ImageLayer {
		let framesFolder: Folder
		let layer: String
		let name: String
	}

	struct SerialText {
		let formatText: NSAttributedString
	}
}
