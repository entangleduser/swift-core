import SwiftUI

struct VisibilityModifier: ViewModifier {
 let show: Bool
 @ViewBuilder func body(content: Content) -> some View {
   content.opacity(show ? 1 : 0)
 }
}

public extension View {
 func visibility(_ isVisible: Bool, animate: Bool = true) -> some View {
  modifier(VisibilityModifier(show: isVisible))
   .transition(.opacity)
   .animation(.easeOut, value: isVisible)
 }
 @_transparent func remove(_ shouldRemove: Bool) -> Self? {
  shouldRemove ? Self?.none : self
 }

 @_transparent func removed() -> Self? {
  Self?.none
 }

 @_transparent func invisible() -> some View {
  opacity(0)
 }

 @_transparent func opaque() -> some View {
  opacity(1)
 }
}
