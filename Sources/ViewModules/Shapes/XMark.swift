import SwiftUI

public struct XMark: Shape {
 public init() {}
 public func path(in frame: CGRect) -> Path {
  Path { path in
   let topTrailing = CGPoint(x: frame.maxX, y: frame.maxY)
   let topLeading = CGPoint(x: frame.minX, y: frame.maxY)
   let bottomTrailing = CGPoint(x: frame.maxX, y: frame.minY)
   path.move(to: frame.origin)
   path.addLine(to: topTrailing)
   path.closeSubpath()
   path.move(to: topLeading)
   path.addLine(to: bottomTrailing)
   path.closeSubpath()
  }
 }
}
