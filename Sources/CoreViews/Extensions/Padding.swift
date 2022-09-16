import SwiftUI

public enum InsetStyle {
 case none
 case standard
 case wide
 case pan // , edge(Edge.Set)
}

public extension View {
 /// Semantic padding for views.
 /// - sizes: 1, 4.5, 8, 11.5, 15, 18.5...((multiples of 3.5) + 1)
 @_transparent
 @ViewBuilder func inset(
  vertical: Edge.Set = .vertical,
  horizontal: Edge.Set = .horizontal,
  _ style: InsetStyle = .wide, _ amount: CGFloat = 8.5
 ) -> some View {
  switch style {
   case .none:
    padding([vertical, horizontal], amount)
   case .standard:
    padding(horizontal, amount / 0.75).padding(vertical, amount)
   case .wide:
    padding(horizontal, amount).padding(vertical, amount / 1.5)
   case .pan:
    padding(horizontal, amount).padding(vertical, amount / 2)
  }
 }

 func insets(_ insets: EdgeInsets) -> some View {
  padding(.top, insets.top)
   .padding(.bottom, insets.bottom)
   .padding(.leading, insets.leading)
   .padding(.trailing, insets.trailing)
 }

 func offsetPadding(x: CGFloat? = 0, y: CGFloat? = 0) -> some View {
  padding(.horizontal, x).padding(.vertical, y)
 }
}
