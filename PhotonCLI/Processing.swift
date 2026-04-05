import Foundation
import CoreImage

/// Process photos with the given parameters.
/// - Parameter params: The processing parameters.
/// - Returns: The list of output file URLs.
func process(params: ProcessingParams) throws -> [URL] {
    try FileManager.default.createDirectory(at: params.outputDir, withIntermediateDirectories: true)

    let ciContext = CIContext()
    var outputFiles: [URL] = []

    for fileURL in params.files {
        let didStartAccessing = fileURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing { fileURL.stopAccessingSecurityScopedResource() }
        }

        guard let ciImage = CIImage(contentsOf: fileURL) else { continue }

        let outputImage = scaled(ciImage, longestSide: params.longestSide)
        let colorSpace = ciImage.colorSpace ?? CGColorSpace(name: CGColorSpace.displayP3)!

        let outputExtension = params.outputFormat == .heif ? "heic" : "jpg"
        let baseName = fileURL.deletingPathExtension().lastPathComponent
        let outputName = (params.prefix ?? "") + baseName + params.suffix + "." + outputExtension
        let outputURL = params.outputDir.appendingPathComponent(outputName)

        switch params.outputFormat {
        case .heif:
            var options: [CIImageRepresentationOption: Any] = [:]
            if params.hdr,
               let gainMap = CIImage(contentsOf: fileURL, options: [.auxiliaryHDRGainMap: true]) {
                options[.hdrGainMapImage] = scaled(gainMap, longestSide: params.longestSide)
            }
            try ciContext.writeHEIFRepresentation(
                of: outputImage,
                to: outputURL,
                format: .BGRA8,
                colorSpace: colorSpace,
                options: options
            )
        case .jpeg:
            try ciContext.writeJPEGRepresentation(of: outputImage, to: outputURL, colorSpace: colorSpace)
        }

        outputFiles.append(outputURL)
    }
    
    return outputFiles
}

private func scaled(_ image: CIImage, longestSide: Double?) -> CIImage {
    guard let longestSide else { return image }
    let size = image.extent.size
    let currentLongest = max(size.width, size.height)
    guard currentLongest > longestSide else { return image }
    let scale = longestSide / currentLongest
    return image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
}
