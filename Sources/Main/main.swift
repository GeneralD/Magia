import CleanCommand
import GenCommand
import SwiftCLI

CLI(name: "magia", version: "1.0.0", description: "Animated NFT generator", commands: [GenCommand(), CleanCommand()]).go()
