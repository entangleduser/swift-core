import SwiftUI
/// A wrapper used to extend and encapsulate description logic.
public struct Description: InfallibleEntry {
 public init() {}
 public static let placeholder: String = "Enter Description ..."
 public enum Error: EntryError {
  case empty, exceededLimit
  public var failureReason: String? {
   switch self {
   case .empty: return "Description must contain 4 or more characters."
   case .exceededLimit: return "Exceeded character limit."
   }
  }
 }

 public static func valid(_ entry: String) -> Result<String, Error> {
  guard entry.count > 3 else { return .failure(.empty) }
  guard entry.utf8.count < 400 else { return .failure(.exceededLimit) }
  return .success(entry)
 }
}
