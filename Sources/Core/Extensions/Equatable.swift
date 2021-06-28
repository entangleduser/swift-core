public extension Equatable {
	@_transparent
	static func == (lhs: Self?, rhs: Self) -> Bool {
		guard let lhs = lhs else { return false }
		return lhs == rhs
	}
}
