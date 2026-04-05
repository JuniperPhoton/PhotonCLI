import Foundation

enum OutputFormat: String, CaseIterable, Codable {
    case jpeg
    case heif
    
    var fileExtension: String {
        switch self {
        case .jpeg:
            "jpeg"
        case .heif:
            "heic"
        }
    }
}

struct EdgeInsets {
    let left: Double
    let top: Double
    let right: Double
    let bottom: Double
    
    var width: Double { left + right }
    var height: Double { top + bottom }
    var isEmpty: Bool { width > 0 && height > 0 }

    init(left: Double, top: Double, right: Double, bottom: Double) {
        self.left = left; self.top = top; self.right = right; self.bottom = bottom
    }

    init(uniform value: Double) {
        self.init(left: value, top: value, right: value, bottom: value)
    }

    /// Parse "left,top,right,bottom" string.
    init?(ltrb string: String) {
        let parts = string.split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        guard parts.count == 4 else { return nil }
        self.init(left: parts[0], top: parts[1], right: parts[2], bottom: parts[3])
    }
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
    let quality: Double?
    let inset: EdgeInsets?
}
