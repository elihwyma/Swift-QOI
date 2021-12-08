//
//  File.swift
//  
//
//  Created by Andromeda on 07/12/2021.
//

#if canImport(AppKit)
import AppKit

private extension NSImage {
    
    convenience init(ciImage: CIImage) {
        let rep = NSCIImageRep(ciImage: ciImage)
        self.init(size: rep.size)
        addRepresentation(rep)
    }
    
}

public extension QOICoder {
    
    class func convert(from png: NSImage) -> Data? {
        guard let cgImage = png.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        return convert(from: cgImage)
    }
    
    class func nsImage(from url: URL, channels: UInt8 = 4, format: CIFormat = .RGBA8) throws -> NSImage? {
        guard let ciImage = try? decode(from: url, channels: channels, format: format) else { return nil }
        return NSImage(ciImage: ciImage)
    }
    
    class func nsImage(from data: Data, channels: UInt8 = 4, format: CIFormat = .RGBA8) -> NSImage? {
        guard let ciImage = decode(from: data, channels: channels, format: format) else { return nil }
        return NSImage(ciImage: ciImage)
    }
    
}

public extension NSImage {
    
    convenience init?(qoiData: Data, channels: UInt8 = 4, format: CIFormat = .RGBA8) {
        guard let decoded = QOICoder.decode(from: qoiData, channels: channels, format: format) else { return nil }
        self.init(ciImage: decoded)
    }
    
    convenience init?(qoiURL: URL, channels: UInt8 = 4, format: CIFormat = .RGBA8) {
        guard let decoded = try? QOICoder.decode(from: qoiURL, channels: channels, format: format) else { return nil }
        self.init(ciImage: decoded)
    }
    
}

#endif
