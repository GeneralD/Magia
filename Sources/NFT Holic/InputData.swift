import CollectionKit
import Files

struct InputData {
	let layers: [ImageLayer]
	let animationDuration: Double

	struct ImageLayer {
		let framesFolder: Folder
		let layer: String
		let name: String
	}
}
