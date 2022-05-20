#if os(iOS)
 import UIKit
#elseif os(macOS)
 import AppKit
#endif
import Combine

/// Decoder for an image that decodes data that can be encoded by `ImageEncoder`
/// Uses `JSONDecoder` to decode base64 data for images and provide extra data.
open class ImageDecoder: TopLevelDecoder {
 public func decode<T>(_ type: T.Type, from data: Data) throws -> T
 where T: Decodable {
  let image = try JSONDecoder().decode(type, from: data) as? SerializedImage
  return image as! T
 }

 public init() {}
 public static let shared = ImageDecoder()
}

/// Encoder for an image that encodes data that can be decoded by `ImageDecoder`
/// Uses `JSONSerialization` to encode base64 data for images and store extra
/// data.
open class ImageEncoder: TopLevelEncoder {
 public func encode<T>(_ value: T) throws -> Data where T: Encodable {
  guard let object = value as? SerializedImage,
        let data = object.imageData else {
   throw EncodingError.invalidValue(
    value,
    .init(
     codingPath: .empty,
     debugDescription: "Invalid input for encoder."
    )
   )
  }

  var dictionary: [String: Any] = ["data": data.base64EncodedString()]
  if let timestamp = object.timestamp {
   dictionary["timestamp"] = timestamp.timeIntervalSinceReferenceDate
  }
  return try JSONSerialization.data(
   withJSONObject: dictionary, options: .empty
  )
 }

 public init() {}
 public static let shared = ImageEncoder()
}

public extension ImageEncoder {
 /// The strategy for encoding a `SerializedImage`.
 enum EncodingStrategy {
  case
   none,
   /// Portable networks graphic format.
   png,
   /// JPEG format.
   /// - parameter compressionQuality: 0 to 1,
   ///  with zero being the highest level of compression.
   jpeg(_ compressionQuality: CGFloat),
   bytes(_ limit: Int)
 }

 static func encode(
  image: NativeImage, using strategy: EncodingStrategy
 ) -> Data? {
  switch strategy {
  case .none, .png: return image.pngData()
  case let .jpeg(quality): return image.jpegData(compressionQuality: quality)
  case let .bytes(limit): return image.compressToBytes(limit: limit)
  }
 }
}

public extension NativeImage {
 #if os(macOS) // TODO: Implement
  func jpegData(compressionQuality _: CGFloat) -> Data? {
   Data()
  }

  func pngData() -> Data? {
   Data()
  }
 #endif
 func compressToBytes(limit: Int) -> Data? {
  var data = jpegData(compressionQuality: 1)
  var quality: CGFloat = 1
  while let count = data?.count, count > limit / 2, quality >= 0 {
   quality -= 0.1
   data = jpegData(compressionQuality: quality)
  }
  return data
 }
}
