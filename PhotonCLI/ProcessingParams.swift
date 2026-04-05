import Foundation

enum OutputFormat: String, CaseIterable, Codable {
    case jpeg
    case heif
}

struct ProcessingParams {
    let files: [URL]
    let hdr: Bool
    let outputFormat: OutputFormat
    let longestSide: Double?
    let outputDir: URL
    let prefix: String?
    let suffix: String
    let recursive: Bool
}
