//
//  QOICoder+UIImage.swift
//  
//
//  Created by Andromeda on 07/12/2021.
//

#if canImport(UIKit)
import UIKit

public extension QOICoder {
    
    class func convert(from png: UIImage) -> Data? {
        guard let cgImage = png.cgImage else { return nil }
        return convert(from: cgImage)
    }
    
    class func uiImage(from url: URL, channels: UInt8 = 4, format: CIFormat = .RGBA8) throws -> UIImage? {
        guard let ciImage = try? decode(from: url, channels: channels, format: format) else { return nil }
        return UIImage(ciImage: ciImage)
    }
    
    class func uiImage(from data: Data, channels: UInt8 = 4, format: CIFormat = .RGBA8) -> UIImage? {
        guard let ciImage = decode(from: data, channels: channels, format: format) else { return nil }
        return UIImage(ciImage: ciImage)
    }

}

public extension UIImage {
    
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
