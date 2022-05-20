import SwiftUI

@available(macOS 11.0, *)
public struct SeratedRowStyle: RowStyle {
 let background: Color
 let separatorColor: Color
 public func body(content: Content) -> some View {
  content
   .rowStyle(
    PlainRowStyle(
     background,
     separator: .dashed(separatorColor),
     separatorLeadSpace: 0
    )
   )
 }

 public init(
  _ background: Color = .background,
  separatorColor: Color = .separator
 ) {
  self.background = background
  self.separatorColor = separatorColor
 }
}
