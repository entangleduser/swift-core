import protocol Core.Infallible
import MapKit
import protocol Storage.JSONCodable
import SwiftUI

@available(macOS 11.0, *)
public struct FullAddress: JSONCodable, Infallible, Equatable, InfallibleEntry {
 public init() {}
 // static let contentType: TextContentType? = .fullStreetAddress
 public var address: String?
 public var city: String?
 public var zip: String?
 public var stateCode: States = .none
 public var completedString: String? {
  guard
   stateCode != .none, let address = address, let city = city, let zip = zip
  else { return nil }
  return "\(address) \(city), \(stateCode.rawValue) \(zip)"
 }

 @_transparent
 public var isIncomplete: Bool { completedString == nil }
 public static let defaultValue: Self = .init()
 public enum Error: EntryError {
  case outOfContext, lookup, api(String)
  public var failureReason: String? {
   switch self {
   case .outOfContext: return "Missing the needed fields to an address."
   case .lookup: return "Coudn't find the address entered."
   case let .api(errorString): return errorString
   }
  }
 }

 public static func valid(_ entry: Self) -> Result<Self, Error> {
  switch entry {
  case let newValue
   where newValue.isIncomplete:
   return .failure(.outOfContext)
  default: return .success(entry)
  }
 }

 public static func lookup(
  _ entry: Self,
  handler: @escaping (Result<Self, Error>) -> Void
 ) {
  switch Self.valid(entry) {
  case let newValue where newValue == .failure(.outOfContext):
   handler(newValue)
  case .success(entry):
   guard let full = entry.completedString else {
    return
   }
   Self.lookup(full) { result in
    switch result {
    case .success: handler(.success(entry))
    case .failure: handler(.failure(.lookup))
    }
   }
  //			guard let completedString = entry.completedString else { return }
  //			let request = MKLocalSearch.Request()
  //			request.naturalLanguageQuery = completedString
  //			let completion: MKLocalSearch.CompletionHandler = { response, error in
  //				if let error = error {
  //					handler(.failure(.api(error.localizedDescription)))
  //				} else {
  //					guard let response = response, !response.mapItems.isEmpty else {
  //						handler(.failure(.lookup))
  //						return
  //					}
  //					handler(.success(entry))
  //				}
  //			}
  //			MKLocalSearch(request: request).start(completionHandler: completion)
  default: break
  }
 }

 public static func lookup(
  _ entry: String,
  handler: @escaping (Result<CLPlacemark, Error>) -> Void
 ) {
  let completion: CLGeocodeCompletionHandler = { placemarks, error in
   if let error = error {
    handler(.failure(.api(error.localizedDescription)))
   } else {
    guard let placemark = placemarks?.first else {
     handler(.failure(.lookup))
     return
    }
    handler(.success(placemark))
   }
  }
  MapController.shared
   .geocodeAddressString(entry, completionHandler: completion)
 }
}
