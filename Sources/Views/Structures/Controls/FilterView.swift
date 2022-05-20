import Algorithms
import SwiftUI

@available(macOS 11.0, *)
public struct FilterView<Options, Label>: View
 where
 Options: Hashable & Equatable & Identifiable & CaseIterable,
 Options.AllCases: RandomAccessCollection,
 Label: View {
 @Binding var filter: [Options]
 let alignment: HorizontalAlignment
 let spacing: CGFloat
 let padding: CGFloat
 let label: (_ selected: Bool,_ state: Control.State,_ option: Options) -> Label

 public var body: some View {
  ScrollView(.horizontal) {
   VStack(alignment: .leading, spacing: spacing) {
    HStack {
     ForEach(Options.allCases) { option in
      let selected = filter.contains(option)
      StateButton(
       action: { state in
        #if os(iOS)
        if state.isFocused {
         FeedbackController.shared.selection.selectionChanged()
        }
        #endif
        withAnimation {
         if let index = filter.firstIndex(of: option) {
          filter.remove(at: index)
         } else { filter.append(option) }
        }
       },
       label: { state in
        label(selected, state, option).transition(.identity)
       }
      )
       .padding(.bottom, padding)
     }
    }
    .padding(.leading)
   }
  }
  #if os(iOS)
  .introspectScrollView { $0.bounces = true }
  #endif
 }

 public init(
  filter: Binding<[Options]> = .constant(.empty),
  alignment: HorizontalAlignment = .leading,
  spacing: CGFloat = 0,
  padding: CGFloat = 0,
  @ViewBuilder label:
   @escaping (Bool, Control.State, Options) -> Label
 ) {
  _filter = filter
  self.alignment = alignment
  self.spacing = spacing
  self.padding = padding
  self.label = label
 }
}
