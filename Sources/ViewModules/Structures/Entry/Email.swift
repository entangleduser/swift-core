import SwiftUI
/// A wrapper used to extend and encapsulate email logic.
public struct Email: InfallibleEntry {
 public init() {}
#if os(iOS)
 public static let keyboardType: UIKeyboardType = .emailAddress
 public static let contentType: TextContentType? = .emailAddress
 #endif
 public static let regexString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
 public enum Error: EntryError {
  case empty, invalidAddress
  public var failureReason: String? {
   switch self {
   case .empty: return "Email cannot be empty."
   case .invalidAddress: return "Invalid email address was entered."
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
