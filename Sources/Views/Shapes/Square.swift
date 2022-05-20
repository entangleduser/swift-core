import SwiftUI

public struct Square: Shape {
 public func path(in frame: CGRect) -> Path {
  Path { path in
   path.move(to: frame.origin)
   path.addRect(.init(origin: .zero, size: .init(width: 2, height: 2)))
   path.closeSubpath()
  }
 }
 public init() {}
}
