import SwiftUI
public struct ZipCode: InfallibleEntry {
 public init() {}
#if !targetEnvironment(macCatalyst) && !os(macOS)
 public static let keyboardType: UIKeyboardType = .numbersAndPunctuation
#endif
 public static let regexString = #"^\d{5}(?:[-\s]\d{4})?$"#
 public enum Error: EntryError {
  case empty, invalidCode
  public var failureReason: String? {
   switch self {
   case .empty: return "Zip Code cannot be empty."
   case .invalidCode: return "Invalid zip code was entered."
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
   return .failure(.invalidCode)
  default: return .success(entry)
  }
 }
}
