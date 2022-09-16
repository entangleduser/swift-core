import SwiftUI

@available(macOS 11.0, *)
public struct DefaultTableStyle: TableStyle {
 public func body(content: Body) -> some View {
  content
 }

 public func content(content: Content) -> some View {
  content
   .contentStyle(DefaultTableContentStyle())
 }

 public func row(content: Row) -> some View {
  content
   .rowStyle(DefaultRowStyle())
 }

 public init() {}
}
