import SwiftCLI

public class CompletionCommand: Command {
	public let name: String
	public let shortDescription = "Generate zsh completions"
	public let longDescription = "You should run this command by sending the output to a file named `_magia` on your $fpath"
	private weak var cli: CLI?

	public init(name: String, cli: CLI) {
		self.name = name
		self.cli = cli
	}

	public func execute() throws {
		guard let cli else { return }
		ZshCompletionGenerator(cli: cli).writeCompletions()
	}
}
