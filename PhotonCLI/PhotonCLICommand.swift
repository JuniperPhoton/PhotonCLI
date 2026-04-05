import Foundation
import ArgumentParser

extension OutputFormat: ExpressibleByArgument {}

struct PhotonCLICommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "photon",
        abstract: "Process photos with various output options."
    )

    @Argument(help: "Input file paths to process.")
    var files: [String]

    @Flag(name: .long, inversion: .prefixedNo, help: "Enable HDR output (default: true). Use --no-hdr to disable.")
    var hdr: Bool = true

    @Option(name: .shortAndLong, help: "Output format: jpeg or heif.")
    var format: OutputFormat = .heif

    @Option(name: .shortAndLong, help: "Longest side in pixels (optional).")
    var longestSide: Double?

    @Option(name: .shortAndLong, help: "Output directory path.")
    var outputDir: String

    @Option(name: .shortAndLong, help: "Optional prefix added to each output filename.")
    var prefix: String?

    @Option(name: .shortAndLong, help: "Suffix added to each output filename before the extension.")
    var suffix: String = "-converted"

    func run() throws {
        let fileURLs = files.map { URL(fileURLWithPath: $0) }
        let outputDirURL = URL(fileURLWithPath: outputDir)

        let params = ProcessingParams(
            files: fileURLs,
            hdr: hdr,
            outputFormat: format,
            longestSide: longestSide,
            outputDir: outputDirURL,
            prefix: prefix,
            suffix: suffix
        )

        let outputFiles = try process(params: params)
        for file in outputFiles {
            print(file.path)
        }
    }
}
