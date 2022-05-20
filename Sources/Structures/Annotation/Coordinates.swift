import Core
/// Represents a location in a graph or coordinate system.
public struct Coordinates: Codable, Hashable, ExpressibleAsZero {
 public var x: Int = 0,
            y: Int = 0,
            width: Int = 0,
            height: Int = 0
 public init() {}
 public init(x: Int = 0, y: Int = 0, width: Int = 0, height: Int = 0) {
  self.x = x
  self.y = y
  self.width = width
  self.height = height
 }
 public static let zero = Self()
}

