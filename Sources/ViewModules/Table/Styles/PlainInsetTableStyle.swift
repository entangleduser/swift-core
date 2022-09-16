import SwiftUI

@available(macOS 11.0, *)
public struct PlainInsetTableStyle: TableStyle {
 public func body(content: Body) -> some View {
  content
   .tableStyle(
    InsetTableStyle(.groupedBackground, shadowColor: .clear)
   )
 }

 public func content(content: Content) -> some View {
  content
 }

 public func row(content: Row) -> some View {
  content
 }

 public init() {}
}
