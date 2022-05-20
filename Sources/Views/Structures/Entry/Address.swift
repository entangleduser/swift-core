import SwiftUI
/// A wrapper used to extend and encapsulate address logic.
public struct Address: InfallibleEntry {
 public init() {}
#if os(iOS)
 public static let contentType: TextContentType? = .streetAddressLine1
 #endif
 public static let regexString = #"\w+(\s\w+){2,}"#
 public enum Error: EntryError {
  case empty, invalidAddress
  public var failureReason: String? {
   switch self {
   case .empty: return "Address cannot be empty."
   case .invalidAddress: return "Invalid address was entered."
   }
  }
 }

 public static func valid(_ entry: String) -> Result<String, Error> {
  switch entry {
  case let newValue where newValue.isEmpty:
   return .failure(.empty)
  case let newValue where
   !NSPredicate(format: "SELF MATCHES %@", Self.regexString)
    .evaluate(with: newValue):
   return .failure(.invalidAddress)
  default: return .success(entry)
  }
 }
}
