import Foundation

public extension URL {
 func data(options: Data.ReadingOptions = .empty) throws -> Data {
  try Data(contentsOf: self, options: options)
 }
}
