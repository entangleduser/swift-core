import SwiftUI

@available(macOS 11.0, *)
public struct OneTimeCode: InfallibleEntry {
 public init() {}
 public static var placeholder: String { "Enter code ..." }
 public static let contentType: TextContentType? = .oneTimeCode
 #if os(iOS)
  public static let keyboardType: UIKeyboardType? = .phonePad
 #endif
 public static var minLength: Int { 6 }
 public enum Error: EntryError {
  case empty, invalidLength
  public var failureReason: String? {
   switch self {
   case .empty: return "Code cannot be empty."
   case .invalidLength: return "Code must be 6 digits."
   }
  }
 }

 // TODO: Add regex checks, after considering the requirements.
 public static func valid(_ entry: String) -> Result<String, Error> {
  switch entry {
  case let entry where entry.isEmpty:
   return .failure(.empty)
  case let entry where entry.utf8.count != minLength:
   return .failure(.invalidLength)
  default: return .success(entry)
  }
 }
}
