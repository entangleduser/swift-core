// MARK: Conforming Types
import Foundation

extension UUID: ExpressibleByNilLiteral {
 public init(nilLiteral _: ()) {
  self.init()
 }
}

public extension RawRepresentable where RawValue: ExpressibleAsEmpty {
 init(nilLiteral _: ()) {
  self.init(rawValue: .empty)!
 }
}

extension Bool: ExpressibleByNilLiteral {
 public init(nilLiteral _: ()) {
  self.init(false)
 }
}

extension Bool: Infallible {}
