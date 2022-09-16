import SwiftUI

public struct EmptyRow<Label>: View where Label: View {
 public init(action: (() -> Void)? = nil, label: @escaping () -> Label) {
  self.action = action
  self.label = label
 }
 var action: (() -> Void)?
 @ViewBuilder var label: () -> Label
 public var body: some View {
  label()
   .maxFrame(align: .center)
   .padding()
   .font(.headline)
   .foregroundColor(.secondaryLabel)
   .onTapGesture(perform: { action?() })
 }
}

public extension EmptyRow where Label == Text {
 init(_ text: String? = .none, action: (() -> Void)? = .none) {
  self.action = action
  label = { Text(text ?? "This list is empty.") }
 }
}
