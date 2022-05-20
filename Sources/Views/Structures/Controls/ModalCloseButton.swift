import SwiftUI

public struct ModalCloseButton: View {
 public init(
  size: CGFloat = 10,
  padding: CGFloat = 0,
  strokeColor: Color = .secondaryLabel,
  background: Color = .tertiaryBackground,
  action: (() -> ())? = .none
 ) {
  self.size = size
  self.padding = padding
  self.strokeColor = strokeColor
  self.background = background
  self.action = action
 }

 @Environment(\.colorScheme) var colorScheme
 @Environment(\.presentationMode) var mode
 private let size: CGFloat
 private let padding: CGFloat
 private let strokeColor: Color
 private let background: Color
 private let action: (() -> ())?
 public var body: some View {
  XMark()
   .stroke(
    strokeColor,
    style:
    StrokeStyle(
     lineWidth: size / 3.33,
     lineCap: .butt,
     lineJoin: .round
    )
   )
   .frame(width: size, height: size)
   .padding(size + 1)
   .background(
    background
     .brightness(colorScheme == .light ? -0.1 : 0.05)
     .mask(Circle())
   )
   .padding(padding)
   .contentShape(Rectangle())
   .onTap(onEnded: onEnded) { selected, view in
    view.opacity(selected ? 0.75 : 1)
   }
 }
 func onEnded() {
  action?() ?? mode.wrappedValue.dismiss()
 }
}
