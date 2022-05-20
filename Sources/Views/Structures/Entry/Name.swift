import protocol Core.Infallible
import SwiftUI
/// A wrapper used to extend and encapsulate username logic.
public struct Name: InfallibleEntry {
 public init() {}
 public static let formatter: PersonNameComponentsFormatter = {
  let formatter = PersonNameComponentsFormatter()
  formatter.style = .long
  return formatter
 }()

 #if os(iOS)
  public static let keyboardType: UIKeyboardType = .default
  public static let contentType: TextContentType? = .name
 #endif
 //	static let regexString = #"^[A-Za-z-,]{3,20}?=.*\d)"#
 public enum Error: EntryError {
  case empty // , invalidName
  public var failureReason: String? {
   switch self {
   case .empty: return "Name cannot be empty."
    //			case .invalidName: return "Invalid name was entered."
   }
  }
 }

 public static func valid(_ entry: String) -> Result<String, Error> {
  switch entry {
  case let newValue where newValue.isEmpty:
   return .failure(.empty)
  //		case let newValue where
  //			!NSPredicate(format: "SELF MATCHES %@", Self.regexString)
  //			.evaluate(with: newValue):
  //			return .failure(.invalidName)
  default: return .success(entry)
  }
 }
}

extension PersonNameComponents: Infallible {
 public static var defaultValue: Self { .init() }
}

public struct FirstName: InfallibleEntry {
 public init() {}
 public static let minLength: Int = 2
 #if os(iOS)
  public static let keyboardType: UIKeyboardType = .default
  public static let contentType: TextContentType? = .givenName
 #endif
 //	static let regexString = #"^[A-Za-z-,]{3,20}?=.*\d)"#
 public enum Error: EntryError {
  case empty // , invalidName
  public var failureReason: String? {
   switch self {
   case .empty: return "Name cannot be empty."
    //			case .invalidName: return "Invalid name was entered."
   }
  }
 }

 public static func valid(_ entry: String) -> Result<String, Error> {
  switch entry {
  case let newValue where newValue.isEmpty:
   return .failure(.empty)
  //		case let newValue where
  //			!NSPredicate(format: "SELF MATCHES %@", Self.regexString)
  //			.evaluate(with: newValue):
  //			return .failure(.invalidName)
  default: return .success(entry)
  }
 }
}

public struct LastName: InfallibleEntry {
 public init() {}
 public static let minLength: Int = 2
 #if os(iOS)
  public static let keyboardType: UIKeyboardType = .default
 public static let contentType: TextContentType? = .familyName
#endif
 //	static let regexString = #"^[A-Za-z-,]{3,20}?=.*\d)"#
 public enum Error: EntryError {
  case empty // , invalidName
  public var failureReason: String? {
   switch self {
   case .empty: return "Name cannot be empty."
    //			case .invalidName: return "Invalid name was entered."
   }
  }
 }

 public static func valid(_ entry: String) -> Result<String, Error> {
  switch entry {
  case let newValue where newValue.isEmpty:
   return .failure(.empty)
  //		case let newValue where
  //			!NSPredicate(format: "SELF MATCHES %@", Self.regexString)
  //			.evaluate(with: newValue):
  //			return .failure(.invalidName)
  default: return .success(entry)
  }
 }
}
