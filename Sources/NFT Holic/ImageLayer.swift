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

	var numberOfFrames: Int {
		layers.map(\.framesFolder.files.array.count).max() ?? 0
	}

	func layerImages(frame: Int) -> [File] {
		layers
			.map(\.framesFolder)
			.filter { !$0.isEmpty(includingHidden: false) }
			.map { layerFolder in
				let sorted = layerFolder.files.array.sorted(at: \.name, by: <)
				return sorted[safe: frame] ?? sorted.last!
			}
	}
}
