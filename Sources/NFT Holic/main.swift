import CollectionKit
import CoreImage
import Files
import Foundation

guard let inputPath = CommandLine.arguments[safe: 1] else { throw Errors.noInputPath }
let animationDuration = CommandLine.arguments[safe: 2].flatMap(Double.init) ?? 2

let root = try Folder(path: inputPath)

let layers = root.subfolders.array
	// sort alphabetically and bigger comes fronter layer
	.sorted(at: \.name, by: <)
	.reduce(into: [InputData.ImageLayer]()) { accum, folder in
		guard let selected = folder.subfolders.array.randomElement() else { return }
		accum.append(.init(framesFolder: selected))
	}

let input = InputData(layers: layers, animationDuration: animationDuration)
let factory = ImageFactory(input: input)

guard let outputPath = Folder.documents else { throw Errors.invalidOutputPath }

guard factory.generateImage(saveIn: outputPath, as: "test.jpg", isPng: false) else { throw Errors.generatingImageFailed }

print("Finish gracefully!")
