import SwiftUI
/// A wrapper used to extend and encapsulate phone logic.
public struct Phone: InfallibleEntry {
 public init() {}
 public static var placeholder: String { "+1 (000) 000-0000" }
 #if os(iOS)
 public static let keyboardType: UIKeyboardType? = .phonePad
 public static let contentType: TextContentType? = .telephoneNumber
 #endif
 public enum Error: EntryError {
  case empty, same, invalidLength, invalidNumber, alreadyRegistered
  public var failureReason: String? {
   switch self {
   case .empty: return "Phone number cannot be empty."
   case .same: return "Number is the same as before."
   case .invalidLength: return "Number must be 10 digits or more."
   case .invalidNumber: return "Number entered was invalid / already exists."
   case .alreadyRegistered: return "Phone number already registered."
   }
  }
 }

 public static func valid(_ entry: String) -> Result<String, Error> {
  switch entry {
  case let entry where entry.isEmpty:
   return .failure(.empty)
  case let entry where entry.count < 10:
   return .failure(.invalidLength)
  default:
   return .success(entry)
  }
 }
}
