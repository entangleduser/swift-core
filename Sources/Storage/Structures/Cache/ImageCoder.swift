#if os(iOS)
  import UIKit
#elseif os(macOS)
  import AppKit
#endif
import Combine
#if os(iOS)
  /// Decoder for an image that decodes data that can be encoded by `ImageEncoder`
  /// Uses `JSONDecoder` to decode base64 data for images and provide extra data.
  open class ImageDecoder: TopLevelDecoder {
    public func decode<T>(
      _ type: T.Type, from data: Data
    ) throws -> T where T: Decodable {
      guard
        let object =
        try JSONDecoder().decode(type, from: data) as? SerializedImage
      else {
        throw DecodingError.dataCorrupted(
          .init(
            codingPath: [],
            debugDescription: "Couldn't read data for decoder."
          )
        )
      }
      return object as! T
    }

    public init() {}
    public static let shared = ImageDecoder()
  }

  /// Encoder for an image that encodes data that can be decoded by `ImageDecoder`
  /// Uses `JSONSerialization` to encode base64 data for images and store extra data.
  open class ImageEncoder: TopLevelEncoder {
    public var encodingStrategy: EncodingStrategy = .png
    public func encode<T>(_ value: T) throws -> Data where T: Encodable {
      guard let object = value as? SerializedImage,
            let image = object.image,
            let data = Self.encode(image: image, using: encodingStrategy)
      else {
        throw EncodingError.invalidValue(
          value,
          .init(
						codingPath: .empty,
            debugDescription: "Invalid input for encoder."
          )
        )
      }
		
			var dictionary: [String: Any] = [
					"id": object.id,
					"image": data.base64EncodedString(),
					"timestamp": object.timestamp.timeIntervalSinceReferenceDate
			]
			if let orientation = object.orientation {
				dictionary["orientation"] = orientation.rawValue
			}
      return
				try JSONSerialization.data(
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
        /// Portable networks graphic format.
        png,
        /// JPEG format.
        /// - parameter compressionQuality: 0 to 1,
        ///  with zero being the highest level of compression.
        jpeg(_ compressionQuality: CGFloat)
    }

    #if os(iOS)
      static func encode(
        image: UIImage, using strategy: EncodingStrategy
      ) -> Data? {
        switch strategy {
        case .png:
          guard let data = image.pngData() else { break }
          return data
        case let .jpeg(quality):
          guard let data =
            image.jpegData(compressionQuality: quality) else { break }
          return data
        }
        return nil
      }

    #elseif os(macOS)
      static func encode(
        image: NSImage, using strategy: EncodingStrategy
      ) -> Data? {
        switch strategy {
        case .png:
          guard let data = image.pngData() else { break }
          return data
        case let .jpeg(quality):
          guard let data =
            image.jpegData(
              compressionQuality: quality
            ) else { break }
          return data
        }
        return nil
      }
    #endif
  }
#endif
