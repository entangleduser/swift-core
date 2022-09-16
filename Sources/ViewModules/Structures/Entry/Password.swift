import SwiftUI

@available(macOS 11.0, *)
public struct Password: InfallibleEntry {
 public init() {}
 public static var minLength: Int { 6 }
 public static let contentType: TextContentType? = .password
 // TODO: Add more specifications.
 public enum Error: EntryError {
  case invalidLength, unmatchedPassword
  public var failureReason: String? {
   switch self {
   case .invalidLength: return "Password must be 6 characters or more."
   case .unmatchedPassword: return "Passwords don't match."
   }
  }
 }

 public static func transform(_: String) -> String? { .none }
 public static func valid(_ entry: String) -> Result<String, Error> {
  guard entry.utf8.count >= minLength else { return .failure(.invalidLength) }
  return .success(entry)
 }
}
