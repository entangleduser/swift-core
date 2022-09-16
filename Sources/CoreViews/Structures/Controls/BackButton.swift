import SwiftUI

@available(macOS 11.0, *)
public struct BackButton<Label>: View where Label: View {
 @Environment(\.presentationMode) var presentationMode
 var spacing: CGFloat?
 var action: (() -> Void)?
 @ViewBuilder var label: () -> Label
 public var body: some View {
  Button(
   action: {
    presentationMode.wrappedValue.dismiss()
    action?()
   },
   label: {
    HStack(alignment: .center, spacing: spacing) {
     Image(systemName: "chevron.left")
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(height: 22)
     label()
    }
    .padding(.leading, 15)
   }
  )
   .buttonStyle(PlainButtonStyle())
 }
}

@available(macOS 11.0, *)
public extension BackButton where Label == Text {
 init(
  _ text: String = .empty,
  spacing: CGFloat? = .none,
  action: (() -> Void)? = .none
 ) {
  self.spacing = spacing
  self.action = action
  label = { Text(text).font(.system(size: 18.5, weight: .semibold)) }
 }
}
