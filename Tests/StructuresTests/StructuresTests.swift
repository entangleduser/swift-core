@testable import Structures
import XCTest

final class Storage: LocationStorage<Any> {
	// properties
}
struct Object: Identifiable {
	var id: UUID = nil
}
struct Value: Identifiable {
	var id: UUID = nil
}
struct HashValue: Hashable {}

struct Values {
	var test: String = "Test"
	var object: Object = .init()
	var object2: Object = .init()
	var value: Value = .init()
	var hashed: HashValue = .init()
}
struct Values2 {
	var test: String = "Test2"
	var object: Object = .init()
	var object2: Object = .init()
	var value: Value = .init()
	var hashed: HashValue = .init()
}
final class StructuresTests: XCTestCase {
	var storage: Storage!
	var values: Values = Values()
//	var dictionary: [Int: String]!
//	var set: Set<String>!
	override func setUp() {
		storage[values, \.test, \.hash] = "Testing"
		print()

//		let strings = (0..<10_000_000).map(
//			{ _ in  ["One", "Two", "Three", "Four"].randomElement()! }
//		)
//		storage = Storage()
//		dictionary = .empty
//		set = Set(strings)
//		strings.forEach {
//			storage._elements[$0.hashValue] = $0
//			dictionary[$0.hashValue] = $0
//		}

	}

	func testStorage() {
		measure {
			print(
				storage.contains("One"),
				storage.contains("Two"),
				storage.contains("Three"),
				storage.contains("Four")
			)
		}
	}


//	func testDictionary() {
//		measure {
//			print(
//			dictionary.contains(where: { $0.key == "One".hashValue }),
//			dictionary.contains(where: { $0.key == "Two".hashValue }),
//			dictionary.contains(where: { $0.key == "Three".hashValue }),
//			dictionary.contains(where: { $0.key == "Four".hashValue })
//			)
//		}
//	}
//
//	func testSet() {
//		measure {
//			print(
//				set.contains("One"),
//				set.contains("Two"),
//				set.contains("Three"),
//				set.contains("Four")
//			)
//		}
//	}
}
