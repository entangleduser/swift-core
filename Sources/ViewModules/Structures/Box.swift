import SwiftUI

public struct Box<Content>: View where Content: View {
 public var alignment: Alignment = .center
 @ViewBuilder public var content: () -> Content
 public var body: some View {
  ZStack(alignment: alignment) {
   content()
  }
 }
}

public extension Box {
 init(
 _ alignment: Alignment = .center,
 @ViewBuilder _ content: @escaping () -> Content
 ) {
  self.alignment = alignment
  self.content = content
 }
}
