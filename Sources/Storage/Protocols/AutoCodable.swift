import Combine

/// An object that conforms to `AutoDecodable` & `AutoEncodable`.
@available(macOS 10.15, iOS 13.0, *)
public typealias AutoCodable = AutoDecodable & AutoEncodable

/// An object with a static, top level decoder.
@available(macOS 10.15, iOS 13.0, *)
public protocol AutoDecodable: Codable {
  associatedtype AutoDecoder: TopLevelDecoder
  /// Decoder used for decoding a `AutoDecodable` object.
  static var decoder: AutoDecoder { get }
}

/// An object with a static, top level encoder.
@available(macOS 10.15, iOS 13.0, *)
public protocol AutoEncodable: Codable {
  associatedtype AutoEncoder: TopLevelEncoder
  /// Encoder used for encoding a `AutoEncodable` object.
  static var encoder: AutoEncoder { get }
}

@available(macOS 10.15, iOS 13.0, *)
extension AutoEncodable {
  public func encoded() throws -> AutoEncoder.Output {
    try Self.encoder.encode(self)
  }
}
