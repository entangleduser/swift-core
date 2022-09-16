import SwiftUI

@available(macOS 11.0, *)
public struct SmallCloseButton: View {
 public init(
  size: CGFloat = 20,
  padding: CGFloat = 1.5,
  background: Color = .label.light,
  action: @escaping () -> ()
 ) {
  self.size = size
  self.padding = padding
  self.background = background
  self.action = action
 }
 private let size: CGFloat
 private let padding: CGFloat
 private let background: Color
 private let action: () -> ()
 
 public var body: some View {
  Image(systemName: "xmark.circle.fill")
   .resizable()
   .aspectRatio(1, contentMode: .fit)
   .frame(width: size)
   .padding(padding)
   .foregroundColor(background)
   .contentShape(Rectangle())
   .onTap(onEnded: action) { selected, view in
    view.opacity(selected ? 0.75 : 1)
   }
 }
}
