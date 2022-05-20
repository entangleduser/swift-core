import struct Storage.Cache
import protocol Storage.JSONCodable
import protocol Storage.CacheExpirable
import SwiftUI

public struct ReverseGeo: JSONCodable, Identifiable, CacheExpirable {
 internal init(id: String = .empty, stateCode: States? = nil, city: String? = nil, zip: String? = nil, address: String? = nil, timestamp: Date = .init()) {
  self.id = id
  self.stateCode = stateCode
  self.city = city
  self.zip = zip
  self.address = address
  self.timestamp = timestamp
 }
 
 public static let expiration: TimeInterval? = 231_600
 // 259_200 // 3 days
// 15_552_000 // 180 days
// 604_800 // 1 week
 public var
  id: String = .empty,
  stateCode: States?,
  city: String?,
  zip: String?,
  address: String?,
  timestamp: Date = .init()
 public var fullAddress: String? {
  guard
   let address = address,
   let city = city,
   let zip = zip,
   let abbreviation = stateCode?.abbreviation else {
   return nil
  }
  return address + " " + zip + " " + city + ", " + abbreviation
 }

 public init() {}
}
