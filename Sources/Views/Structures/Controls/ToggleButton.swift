import SwiftUI

public struct ToggleButton<Options, Label>: View
 where
 Options: Equatable & CaseIterable,
 //	Options.AllCases: RandomAccessCollection,
 Label: View {
 @Binding var selection: Options.AllCases.Element
 var filter: ((Options.AllCases.Element) -> Bool)?
 let action: ((Options.AllCases.Element) -> Void)?
 let label: (_ option: Options.AllCases.Element) -> Label
 public var body: some View {
  Button(
   action: {
    selection = selection.next(with: filter) ?? selection.next
    action?(selection)
   },
   label: { label(selection) }
  )
 }

 public init(
  selection: Binding<Options>,
  filter: ((Options.AllCases.Element) -> Bool)? = .none,
  action: ((Options.AllCases.Element) -> Void)? = .none,
  @ViewBuilder label:
  @escaping (Options.AllCases.Element) -> Label
 ) {
  _selection = selection
  self.label = label
  self.action = action
  self.filter = filter
 }
}
