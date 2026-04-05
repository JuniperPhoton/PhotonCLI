import Foundation
import CoreImage
import UniformTypeIdentifiers

/// Process photos with the given parameters.
/// - Parameter params: The processing parameters.
/// - Returns: The list of output file URLs.
func process(params: ProcessingParams) throws -> [URL] {
    try FileManager.default.createDirectory(at: params.outputDir, withIntermediateDirectories: true)
    
    let expandedFiles = try params.files.flatMap { url -> [URL] in
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) else { return [] }
        guard isDir.boolValue else { return [url] }
        if params.recursive {
            let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey])
            return (enumerator?.compactMap { $0 as? URL } ?? [])
        } else {
            return try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        }
    }
    
    let supportedTypes: [UTType] = [.png, .jpeg, .heic, .tiff]
    let imageFiles = expandedFiles.filter { url in
        guard let type = UTType(filenameExtension: url.pathExtension) else { return false }
        return supportedTypes.contains { type.conforms(to: $0) }
    }
    
    let ciContext = CIContext()
    var outputFiles: [URL] = []
    
    for fileURL in imageFiles {
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
        
        var options: [CIImageRepresentationOption: Any] = [:]
        if params.hdr,
           let gainMap = CIImage(contentsOf: fileURL, options: [.auxiliaryHDRGainMap: true]) {
            options[.hdrGainMapImage] = scaled(gainMap, longestSide: params.longestSide)
        }
        
        switch params.outputFormat {
        case .heif:
            try ciContext.writeHEIFRepresentation(
                of: outputImage,
                to: outputURL,
                format: .BGRA8,
                colorSpace: colorSpace,
                options: options
            )
        case .jpeg:
            try ciContext.writeJPEGRepresentation(
                of: outputImage,
                to: outputURL,
                colorSpace: colorSpace,
                options: options
            )
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
