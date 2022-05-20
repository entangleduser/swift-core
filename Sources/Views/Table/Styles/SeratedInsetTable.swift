import SwiftUI

@available(macOS 11.0, *)
public struct SeratedInsetTableStyle: TableStyle {
 private let showsLine: Bool

 public func body(content: Body) -> some View {
  content
 }

 public func content(content: Content) -> some View {
  content
   .contentStyle(InsetTableContentStyle())
   .modifier(BorderModifier(showsLine: showsLine))
 }

 public func row(content: Row) -> some View {
  content
   .rowStyle(SeratedRowStyle())
 }

 public init(showsLine: Bool = false) {
  self.showsLine = showsLine
 }
}
