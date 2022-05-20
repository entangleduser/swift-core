import SwiftUI

@available(macOS 11.0, *)
public struct Separator: View {
 private let color: Color?
 private let lineWidth: CGFloat
 private let dash: [CGFloat]

 public var body: some View {
  Divider()
   .invisible()
   .separator(
    color ?? .separator,
    lineWidth: lineWidth,
    dash: dash
   )
   .offset(y: -0.75)
 }

 public init(
  color: Color? = nil,
  lineWidth: CGFloat = 0.5,
  dash: [CGFloat] = []
 ) {
  self.color = color
  self.lineWidth = lineWidth
  self.dash = dash
 }
}
