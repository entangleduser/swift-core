import SwiftUI
public struct City: InfallibleEntry {
 public init() {}
 #if os(iOS)
 public static let contentType: TextContentType? = .addressCity
 #endif
 public enum Error: EntryError {
  case empty
  public var failureReason: String? {
   switch self {
   case .empty: return "City cannot be empty."
   }
  }
 }

 public static func valid(_ entry: String) -> Result<String, Error> {
  switch entry {
  case let newValue where newValue.isEmpty:
   return .failure(.empty)
  default: return .success(entry)
  }
 }
}
