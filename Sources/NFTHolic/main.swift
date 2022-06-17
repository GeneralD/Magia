import SwiftCLI

CLI(name: "nftholic", version: "1.0.0", description: "Animated NFT generator", commands: [GenCommand(), CleanCommand()]).go()
