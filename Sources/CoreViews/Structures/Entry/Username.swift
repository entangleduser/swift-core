import SwiftUI
/// A wrapper used to extend and encapsulate username logic.
@available(macOS 11.0, *)
public struct Username: InfallibleEntry {
 public init() {}
 public static let contentType: TextContentType? = .username
 public enum Error: EntryError {
  case invalidLength, alreadyExists
  public var failureReason: String? {
   switch self {
   case .invalidLength: return "Username must be 4 characters or more."
   case .alreadyExists: return "Username already exists."
   }
  }
 }

 public static func valid(_ entry: String) -> Result<String, Error> {
  guard entry.utf8.count >= 4 else { return .failure(.invalidLength) }
  //		guard container[Profile.self, where: "id", equals: entry].count == 0
  //		else { return .failure(.alreadyExists) }
  return .success(entry)
 }
}
