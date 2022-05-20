import Foundation

public extension Error {
 var message: String {
  (self as? LocalizedError)?.failureReason ?? localizedDescription
 }
 func debugPrint() {
  Swift.debugPrint(self, _code, message, terminator: "\n")
 }
}
