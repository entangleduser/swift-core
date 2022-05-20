import protocol Core.Infallible
import SwiftUI
import class SwiftUI.Formatter
#if os(iOS)
 public typealias TextContentType = UITextContentType
#elseif os(macOS)
 public typealias TextContentType = NSTextContentType
#endif
public protocol InfallibleEntry: Hashable {
 associatedtype Value: Infallible & Equatable
 associatedtype Error: EntryError
 static var minLength: Int { get }
 static var formatter: Formatter! { get }
 static var placeholder: String { get }
 #if os(iOS)
  static var keyboardType: UIKeyboardType { get }
 #endif
 static var contentType: TextContentType? { get }
 static func transform(_ value: Value) -> Value?
 /// Validates the entered value and returns a result..
 static func valid(_ entry: Value) -> Result<Value, Error>
 init()
}

public extension InfallibleEntry {
 @_transparent
 static var minLength: Int { 4 }
 @_transparent
 static var formatter: Formatter! { .none }
 @_transparent
 static var placeholder: String { "Set \(description)" }
 #if os(iOS)
  @_transparent
  static var keyboardType: UIKeyboardType { .default }
 #endif
 @_transparent
 static var contentType: TextContentType? { .none }
 @_transparent
 static func transform(_: Value) -> Value? { .none }
 @_transparent
 static var description: String { String(describing: Self.self) }
}

public extension InfallibleEntry where Value == Int {
 @inline(__always)
 static var formatter: Formatter! { NumberFormatter() }
}

public extension InfallibleEntry where Value == String {
 @_transparent
 static func transform(_ string: Value) -> Value? {
  string.trimmed
 }
}
