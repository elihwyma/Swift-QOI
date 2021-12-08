# Swift-QOI
Swift implementation of the [QOI Format](https://github.com/phoboslab/qoi). Contains extensions for AppKit and UIKit to integrate into your projects with ease.

## Documentation 
```swift
// Convert a UIImage/NSImage/CIImage to QOI Data
let image = UIImage(named: "ExamplePNG")!
let encoded = QOICoder.convert(from: image) // Returns Data

// Load a QOI Image from Data to UIImage/NSImage/CIImage
let imageURL = Bundle.main.url(forResource: "TestImage", withExtension: "qoi")!
let data = try! Data(contentsOf: imageURL)

// UIImage
let uiImage = UIImage(qoiData: data)
// or // 
let uiImage = UIImage(qoiURL: imageURL)

// NSImage
let nsImage = NSImage(qoiData: data) 
// or // 
let nsImage = NSImage(qoiURL: imageURL)

// CIImage 
let ciImage = QOICoder.decode(from: data)
```
## License 
* Swift-QOI is licensed under [MIT](https://github.com/elihwyma/Swift-QOI/blob/main/LICENSE)
* qoi.h is licensed under MIT
