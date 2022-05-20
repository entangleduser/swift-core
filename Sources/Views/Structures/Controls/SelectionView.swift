import SwiftUI
public struct SelectionView<Options, Label>: View
 where
 Options: Identifiable & Hashable & Equatable & CaseIterable,
 Options.AllCases: RandomAccessCollection,
 Label: View {
 @Binding var selection: Options
 let axis: Axis.Set
 let alignment: Alignment
 let spacing: CGFloat?
 let padding: CGFloat
  let label: (_ selected: Bool, _ state: Control.State, _ option: Options) -> Label
 @ViewBuilder
 var content: some View {
  ForEach(Options.allCases) { option in
   StateButton(
    action: { withAnimation { selection = option } },
    label: { state in
     label(option == selection, state, option)
    }
   )
  }
 }

 public var body: some View {
  ScrollView(axis, showsIndicators: false) {
   if axis == .horizontal {
    HStack(alignment: alignment.vertical, spacing: spacing) {
     content
    }
    .padding(.horizontal, padding)
   } else {
    VStack(alignment: alignment.horizontal, spacing: spacing) {
     content
    }
    .padding(.vertical, padding)
   }
  }
  #if os(iOS)
  .introspectScrollView { $0.bounces = true }
  #endif
 }

 public init(
  selection: Binding<Options>,
  axis: Axis.Set = .horizontal,
  alignment: Alignment = .center,
  spacing: CGFloat? = .none,
  padding: CGFloat = 0,
  @ViewBuilder label:
  @escaping (Bool, Control.State, Options) -> Label
 ) {
  _selection = selection
  self.axis = axis
  self.alignment = alignment
  self.spacing = spacing
  self.padding = padding
  self.label = label
 }
}
