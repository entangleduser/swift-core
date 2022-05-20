import Combine
import Foundation
import Core
import Reflection

/// An object that conforms to `AutoDecodable` & `AutoEncodable`.
public protocol AutoCodable:
 AutoDecodable & AutoEncodable & Changeable
where AutoDecoder.Input == Data, AutoDecoder.Input == AutoEncoder.Output {
 static var decoder: AutoDecoder { get }
 static var encoder: AutoEncoder { get }
}

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
public extension AutoEncodable {
 func encoded() throws -> AutoEncoder.Output {
  try Self.encoder.encode(self)
 }

 var data: AutoEncoder.Output? { try? encoded() }
}

extension Optional: AutoEncodable where Wrapped: AutoEncodable {
 public static var encoder: Wrapped.AutoEncoder {
  Wrapped.encoder
 }
}

extension Optional: AutoDecodable where Wrapped: AutoDecodable {
 public static var decoder: Wrapped.AutoDecoder {
  Wrapped.decoder
 }
}

extension Optional: Changeable where Wrapped: AutoCodable {
 @discardableResult
 public func change(_ handler: @escaping (inout Self) -> ()) -> Self { @discardableResult
  func change(_ handler: @escaping (inout Self) -> ()) -> Self {
   var changing = self
   handler(&changing)
   return changing
  }

  fatalError("Value must be unwrapped before mutating!")
 }
}

extension Optional: AutoCodable where Wrapped: AutoCodable {}

public extension AutoCodable {
 typealias Storage = Cache<Self>
 private var mirror: Mirror {
  Mirror(reflecting: self)
 }
 static var members: [String: String] {
  Dictionary(
   uniqueKeysWithValues:
    StructMetadata(type: Self.self).toTypeInfo().properties.map { property in
     (
      property.name,
      StructMetadata(type: property.type).toTypeInfo().name
     )
    }
  )
 }
 var isEmpty: Bool { dictionary.isEmpty }
 var notEmpty: Bool { !isEmpty }
 var wrapped: Self? { isEmpty ? .none : self }
 var dictionary: [String: Any] { // TODO: Handle missing values with `StructMetadata`?
  Dictionary(
   uniqueKeysWithValues:
    mirror.children.map { ($0.label!, $0.value) }
  )
 }
}

extension TopLevelDecoder where Input == Data {
 public func decode<A: Decodable>(
  contentOf url: URL,
  options: Data.ReadingOptions = .empty,
  _ type: A.Type
 ) throws -> A {
  try decode(type, from: try Data(contentsOf: url, options: options))
 }
}
