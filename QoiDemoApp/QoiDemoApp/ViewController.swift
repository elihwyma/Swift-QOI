//
//  ViewController.swift
//  QoiDemoApp
//
//  Created by Somica on 08/12/2021.
//

import UIKit
import SwiftQOI

class ViewController: UIViewController {
    
    @IBOutlet weak var imageViewOne: UIImageView!
    @IBOutlet weak var imageViewTwo: UIImageView!
    @IBOutlet weak var imageViewThree: UIImageView!
    
    public var _cacheDirectory: URL = {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent((Bundle.main.infoDictionary?[kCFBundleNameKey as String] as! String).replacingOccurrences(of: " ", with: ""))
    }()
    
    func measureElapsedTime(_ block: () -> Void) {
        let start = CFAbsoluteTimeGetCurrent()
        block()
        let end = CFAbsoluteTimeGetCurrent() - start
        NSLog("Execution of block took \(end) seconds")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let image = Bundle.main.url(forResource: "TestImage", withExtension: "png")!
        let data = try! Data(contentsOf: image)
        measureElapsedTime {
            let image = UIImage(data: data)
            imageViewOne.image = image
        }
        
        let uiImage = UIImage(data: data)!
        let encoded = QOICoder.convert(from: uiImage)!
        measureElapsedTime {
            let decoded = UIImage(qoiData: encoded)
            imageViewTwo.image = decoded
        }

        NSLog("Size of the png is \(image.fileSizeString)")
        try? FileManager.default.createDirectory(at: _cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        let qoiURL = _cacheDirectory.appendingPathComponent("TestImage").appendingPathExtension("qoi")
        try! encoded.write(to: qoiURL)
        NSLog("Size of the qoi is \(qoiURL.fileSizeString)")
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

            let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 1)
            contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))

            pixelValues = intensities
        }

        return (pixelValues, width, height)
    }
}

public extension URL {
    var attributes: [FileAttributeKey: Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }

    var size: UInt64 {
        attributes?[.size] as? UInt64 ?? UInt64(0)
    }

    var fileSizeString: String {
        ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }

    var creationDate: Date? {
        attributes?[.creationDate] as? Date
    }
    
    var exists: Bool {
        FileManager.default.fileExists(atPath: path)
    }

    var dirExists: Bool {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    func contents() throws -> [URL] {
        try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil)
    }

    var implicitContents: [URL] {
        (try? contents()) ?? []
    }
}
