import SwiftUI

public struct Triangle: Shape {
 public init() {}
 public func path(in rect: CGRect) -> Path {
  Path { path in
   let topCenter = CGPoint(x: rect.midX, y: rect.minY)
   let bottomLeading = CGPoint(x: rect.minX, y: rect.maxY)
   let bottomTrailing = CGPoint(x: rect.maxX, y: rect.maxY)
   path.move(to: topCenter)
   path.addLine(to: bottomLeading)
   path.addLine(to: bottomTrailing)
   path.addLine(to: topCenter)
   path.closeSubpath()
  }
 }
}
