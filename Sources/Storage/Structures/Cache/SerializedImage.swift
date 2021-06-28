#if os(iOS)
	import UIKit

	// TODO: Add timestamp/id based invalidation
	/// A class for cached images that can be used with `Cache` after
	///  conforming to `CacheExpirable`.
	public protocol SerializedImage: CacheExpirable {
		var id: String { get set }
		var image: UIImage? { get set }
		var orientation: UIImage.Orientation? { get set }
		init()
	}

	public extension SerializedImage {
		init(from decoder: Decoder) throws {
			self.init()
			let container =
				try decoder.container(keyedBy: SerializedImageKey.self)
			let data =
				try container.decode(Data.self, forKey: .image)
			guard
				let image = UIImage(data: data)
			else {
				throw DecodingError.dataCorrupted(
					.init(
						codingPath: container.codingPath,
						debugDescription: "Data couldn't be read for image."
					)
				)
			}

			id = try container.decode(String.self, forKey: .id)
			if let intValue =
				try container.decodeIfPresent(
					Int.self,
					forKey: .orientation
				),
				let orientation = UIImage.Orientation(rawValue: intValue) {
				self.orientation = orientation
//				guard let cgImage = image.cgImage else { return }
//				self.image =
//					UIImage(cgImage: cgImage, scale: image.scale, orientation: orientation)
//			} else {
//				self.image = image
			}
			self.image = image

			timestamp =
				Date(
					timeIntervalSinceReferenceDate:
					try container.decode(
						TimeInterval.self,
						forKey: .timestamp
					)
				)
		}

		func encode(to _: Encoder) throws {}
		static var encoder: ImageEncoder { ImageEncoder.shared }
		static var decoder: ImageDecoder { ImageDecoder.shared }
		init(
			id: String = UUID().uuidString,
			_ image: UIImage? = .none,
			_ orientation: UIImage.Orientation? = .none,
			_ timestamp: Date = .init()
		) {
			self.init()
			self.id = id
			self.image = image
//			if let orientation = orientation {
				self.orientation = orientation
//				guard let image = self.image, let cgImage = image.cgImage else { return }
//				self.image =
//					UIImage(cgImage: cgImage, scale: image.scale, orientation: orientation)
//			}
			self.timestamp = timestamp
		}
	}

	/// Coding key for encoding / decoding a `SerializedImage`
	enum SerializedImageKey: CodingKey {
		case id, image, orientation, timestamp
	}
#endif
