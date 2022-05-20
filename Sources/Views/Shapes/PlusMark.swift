import SwiftUI

public struct PlusMark: Shape {
 public init() {}
 public func path(in frame: CGRect) -> Path {
  Path { path in
   let bottomMid = CGPoint(x: frame.midX, y: frame.minY)
   let topMid = CGPoint(x: frame.midX, y: frame.maxY)
   let midLeading = CGPoint(x: frame.minX, y: frame.midY)
   let midTrailing = CGPoint(x: frame.maxX, y: frame.midY)
   path.move(to: bottomMid)
   path.addLine(to: topMid)
   path.closeSubpath()
   path.move(to: midLeading)
   path.addLine(to: midTrailing)
   path.closeSubpath()
  }
 }
}
