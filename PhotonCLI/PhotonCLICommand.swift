import Foundation
import ArgumentParser

extension OutputFormat: ExpressibleByArgument {}

struct PhotonCLICommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "photoncli",
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

    @Flag(name: .long, inversion: .prefixedNo, help: "Recursively process files in subdirectories (default: true).")
    var recursive: Bool = true

    @Option(name: .shortAndLong, help: "Output quality from 0.0 (lowest) to 1.0 (highest). Omit to use the system default.")
    var quality: Double?

    @Option(name: .long, help: "Uniform inset (in pixels) to crop from all sides.")
    var inset: Double?

    @Option(name: .long, help: "Per-side inset (in pixels) as \"left,top,right,bottom\" to crop from each edge.")
    var insetLtrb: String?

    func run() throws {
        let fileURLs = files.map { URL(fileURLWithPath: $0) }
        let outputDirURL = URL(fileURLWithPath: outputDir)

        let resolvedInset: EdgeInsets?
        if let ltrb = insetLtrb {
            guard let parsed = EdgeInsets(ltrb: ltrb) else {
                throw ValidationError("--inset-ltrb must be four comma-separated numbers, e.g. \"10,10,10,10\".")
            }
            resolvedInset = parsed
        } else if let uniform = inset {
            resolvedInset = EdgeInsets(uniform: uniform)
        } else {
            resolvedInset = nil
        }

        let params = ProcessingParams(
            files: fileURLs,
            hdr: hdr,
            outputFormat: format,
            longestSide: longestSide,
            outputDir: outputDirURL,
            prefix: prefix,
            suffix: suffix,
            recursive: recursive,
            quality: quality,
            inset: resolvedInset
        )

        let outputFiles = try process(params: params)
        for file in outputFiles {
            print(file.path)
        }
    }
}
