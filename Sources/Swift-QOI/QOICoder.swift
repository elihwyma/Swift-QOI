//  Created by Andromeda on 07/12/2021.
//

import Foundation
import CoreImage
import SQOI

/*
 - qoi_read    -- read and decode a QOI file
 - qoi_decode  -- decode the raw bytes of a QOI image from memory
 - qoi_write   -- encode and write a QOI file
 - qoi_encode  -- encode an rgba buffer into a QOI image in memory
 */
final public class QOICoder {

    public class func decode(from url: URL, channels: UInt8 = 4, format: CIFormat = .RGBA8) throws -> CIImage? {
        do {
            let data = try Data(contentsOf: url)
            return decode(from: data, channels: channels, format: format)
        } catch {
            throw error
        }
    }
    
    // 4 Channels is for a standard RGBA image, good enough 99% of the time
    public class func decode(from data: Data, channels: UInt8 = 4, format: CIFormat = .RGBA8) -> CIImage? {
        guard let (qoiData, height, width) = _decode(from: data, channels: channels, format: format) else { return nil }
        let bytesPerRow = width * 4
        let size = CGSize(width: width, height: height)
        let image = CIImage(bitmapData: qoiData,
                            bytesPerRow: bytesPerRow,
                            size: size,
                            format: format,
                            colorSpace: CGColorSpaceCreateDeviceRGB())
        return image
    }
    
    public class func _decode(from data: Data, channels: UInt8 = 4, format: CIFormat = .RGBA8) -> (Data, Int, Int)? {
        var desc = qoi_desc(width: 0, height: 0, channels: channels, colorspace: 0)
        
        guard let bytes = data.withUnsafeBytes({ $0.baseAddress }),
              let pixelData = SQOI.qoi_decode(bytes, Int32(data.count), &desc, Int32(channels)) else { return nil }
        defer {
            pixelData.deallocate()
        }

        let height = Int(desc.height)
        let width = Int(desc.width)
        
        let pixelCount = height * width
        let dataCount = pixelCount * (Int(channels) + 1) + Int(SQOI.QOI_PADDING) + Int(SQOI.QOI_HEADER_SIZE)

        let qoiData = Data(bytes: pixelData, count: dataCount)
        return (qoiData, height, width)
    }
    
    private class func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }
    
    public class func convert(from png: CIImage) -> Data? {
        guard let cgImage = convertCIImageToCGImage(inputImage: png),
              let convert = convert(from: cgImage) else { return nil }
        return convert
    }
    
    public class func convert(from png: CGImage) -> Data? {
        let (pixels, width, height) = png.pixelValues()
        var desc = qoi_desc(width: UInt32(width), height: UInt32(height), channels: 4, colorspace: 0)
        guard let pixels = pixels,
              let pointer = Data(pixels).withUnsafeBytes({ $0.baseAddress }) else { return nil }
        var size: Int32 = 0
        let encoded = qoi_encode(pointer, &desc, &size)
        defer {
            encoded?.deallocate()
        }
        guard size != 0,
              let encoded = encoded else { return nil }
        return Data(bytes: encoded, count: Int(size))
    }
}

private extension CGImage {
    func pixelValues() -> (pixelValues: [UInt8]?, width: Int, height: Int) {
        pixelValues(fromCGImage: self)
    }
    
    func pixelValues(fromCGImage imageRef: CGImage?) -> (pixelValues: [UInt8]?, width: Int, height: Int) {
        var width = 0
        var height = 0
        var pixelValues: [UInt8]?
        if let imageRef = imageRef {
            width = imageRef.width
            height = imageRef.height
            let bitsPerComponent = imageRef.bitsPerComponent
            let bytesPerRow = imageRef.bytesPerRow
            let totalBytes = height * bytesPerRow

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            var intensities = [UInt8](repeating: 0, count: totalBytes)

            let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
            contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))

            pixelValues = intensities
        }

        return (pixelValues, width, height)
    }
}
