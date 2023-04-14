import CleanCommand
import CompletionCommand
import EnchantCommand
import Foundation
import SummonCommand
import SwiftCLI

let cli = CLI(name: "magia", version: "1.0.5", description: "Ultimate NFT generator")

cli.commands = [
	SummonCommand(name: "summon"),
	EnchantCommand(name: "enchant"),
	CleanCommand(name: "clean"),
	CompletionCommand(name: "completions", cli: cli)
]

exit(cli.go())
