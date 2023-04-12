import CleanCommand
import CompletionCommand
import EnchantCommand
import Foundation
import GenCommand
import SwiftCLI

let cli = CLI(name: "magia", version: "1.0.5", description: "Ultimate NFT generator")

cli.commands = [
	GenCommand(name: "summon"),
	EnchantCommand(name: "enchant"),
	CleanCommand(name: "clean"),
	CompletionCommand(name: "completions", cli: cli)
]

exit(cli.go())
