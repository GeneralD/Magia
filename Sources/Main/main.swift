import CleanCommand
import EnchantCommand
import GenCommand
import SwiftCLI

CLI(
	name: "magia",
	version: "1.0.0",
	description: "Ultimate NFT generator",
	commands: [
		GenCommand(name: "summon"),
		EnchantCommand(name: "enchant"),
		CleanCommand(name: "clean"),
	]).go()
