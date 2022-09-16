import Storage
import SwiftUI

public struct ImageCache: SerializedImage, Hashable, AutoCodable {
 public static let expiration: TimeInterval? = 288_000
 public static let memory: Memory = .shared
 public var imageData: Data?
 public var timestamp: Date? = .init()
 public init() {}
}

extension ImageCache {
 open class Memory {
  public static let shared = Memory()
  public var thumbnails: [String: [Int: ImageCache]] = .empty
  public var images: [String: ImageCache] = .empty
  public func remove(_ id: String) {
    thumbnails[id] = nil
    images[id] = nil
  }
 }
}
