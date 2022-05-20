import SwiftUI

@available(macOS 11.0, *)
public struct DefaultRowStyle: RowStyle {
 public func body(content: Content) -> some View {
  content
   .rowStyle(PlainRowStyle(
    .background,
    separatorLeadSpace: 16
   )
   )
 }

 public init() {}
}
