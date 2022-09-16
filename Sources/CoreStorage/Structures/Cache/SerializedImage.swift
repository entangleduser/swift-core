#if os(iOS)
 import UIKit
 public typealias NativeImage = UIImage
#elseif os(macOS)
 import AppKit
 public typealias NativeImage = NSImage
#endif

/// A protocol for cached images that can be used with `Cache` after conforming
/// to `CacheExpirable`.
public protocol SerializedImage: CacheExpirable {
 var imageData: Data? { get set }
 var timestamp: Date? { get set }
 static var encodingStrategy: ImageEncoder.EncodingStrategy { get }
 init()
}

public extension SerializedImage {
 static var expiration: TimeInterval? {
  231_600
  // 1.8144e+06 // 3 week
  //15_552_000 // 180 days
 }

 static var encodingStrategy: ImageEncoder.EncodingStrategy { .none }
 static var encoder: ImageEncoder { ImageEncoder.shared }
 static var decoder: ImageDecoder { ImageDecoder.shared }
 var image: NativeImage? {
  guard let data = imageData else { return nil }
  return NativeImage(data: data)
 }

 func encode(to encoder: Encoder) throws {
  var container = encoder.container(keyedBy: SerializedImageKey.self)
  try container.encode(imageData?.base64EncodedString(), forKey: .data)
  try container.encode(
   timestamp?.timeIntervalSinceReferenceDate,
   forKey: .timestamp
  )
 }

 init(from decoder: Decoder) throws {
  self.init()
  let container = try decoder.container(keyedBy: SerializedImageKey.self)
  imageData = try container.decode(Data.self, forKey: .data)
  if let interval =
   try container.decodeIfPresent(Double.self, forKey: .timestamp) {
   timestamp = Date(timeIntervalSinceReferenceDate: interval)
  }
 }

 init(
  _ image: NativeImage? = .none,
  _ timestamp: Date? = .none,
  strategy: ImageEncoder.EncodingStrategy
 ) {
  self.init()
  guard let image = image,
        let data = ImageEncoder.encode(image: image, using: strategy)
  else { return }
  imageData = data
  self.timestamp = timestamp
 }

 init(
  _ image: NativeImage? = .none,
  _ timestamp: Date? = .none
 ) {
  self.init()
  guard let image = image, let data = image.pngData()
  else { return }
  imageData = data
  self.timestamp = timestamp
 }
}

/// Coding key for encoding / decoding a `SerializedImage`
enum SerializedImageKey: CodingKey {
 case data, timestamp
}
