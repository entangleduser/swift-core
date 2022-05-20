import SwiftUI

public struct RoundedPath: Shape {
 public init(radius: CGFloat = .infinity, corners: CornerSet = .all) {
  self.radius = radius
  self.corners = corners
 }

 var radius: CGFloat = .infinity
 var corners: CornerSet = .all
 public func path(in rect: CGRect) -> Path {
  Path(rect: rect, corners: corners, radius: radius)
 }
}

public extension View {
 func cornerRadius(_ corners: CornerSet, _ radius: CGFloat) -> some View {
  clipShape(RoundedPath(radius: radius, corners: corners))
 }
}
