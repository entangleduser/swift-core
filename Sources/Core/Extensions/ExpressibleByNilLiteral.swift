// MARK: Conforming Types
import Foundation

extension UUID: ExpressibleByNilLiteral {
	public init(nilLiteral: ()) {
		self.init()
	}
}

public extension RawRepresentable where RawValue: ExpressibleAsEmpty {
	init(nilLiteral: ()) {
		self.init(rawValue: .empty)!
	}
}

extension Bool: ExpressibleByNilLiteral {
	public init(nilLiteral: ()) {
		self.init(false)
	}
}

extension Bool: Infallible {}
