import CleanCommand
import CompletionCommand
import EnchantCommand
import Foundation
import BoilerplateCommand
import SummonCommand
import SwiftCLI

let cli = CLI(name: "magia", version: "1.0.7", description: "Ultimate NFT generator")

cli.commands = [
	SummonCommand(name: "summon"),
	EnchantCommand(name: "enchant"),
	BoilerplateCommand(name: "boilerplate"),
	CleanCommand(name: "clean"),
	CompletionCommand(name: "completions", cli: cli)
]

exit(cli.go())
