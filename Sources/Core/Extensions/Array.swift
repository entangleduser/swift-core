extension Array {
	subscript(first where: @escaping (Element) -> Bool) -> Element? {
		get { first(where: `where`) }
		mutating set {
			if let index = firstIndex(where: `where`) {
				guard let newValue = newValue else {
					self.remove(at: index)
					return
				}
				self[index] = newValue
			}
		}
	}
}

public extension Array where Element: Equatable {
	mutating func removeAll(_ element: Element) {
		removeAll(where: { $0 == element })
	}
}
