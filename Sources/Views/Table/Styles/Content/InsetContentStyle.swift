import SwiftUI
import Colors

@available(macOS 11.0, *)
public struct InsetTableContentStyle: TableContentStyle {
 private let background: Color
 private let contentBackground: Color
 private let cornerRadius: CGFloat
 private let shadowColor: Color
 private let shadowRadius: CGFloat
 private let shadowOffset: CGPoint

 public func body(content: Content) -> some View {
  content
   .contentStyle(DefaultTableContentStyle(showsLine: false))
   .offset(y: 1)
   .background(contentBackground)
   .maxFrame(align: .center)
   .cornerRadius(cornerRadius)
   .offsetPadding(x: 25, y: 11.5)
   .shadow(color: shadowColor,
           radius: shadowRadius,
           x: shadowOffset.x,
           y: shadowOffset.y)
    .introspectScrollView {
     $0.backgroundColor = background.nativeColor
    }
    .introspectNavigationController {
     $0.navigationBar.backgroundColor = .clear
    }
 }

 public init(
  _ background: Color = .groupedBackground,
  contentBackground: Color = .background,
  cornerRadius: CGFloat = 15,
  shadowColor: Color = .secondaryLabel,
  shadowRadius: CGFloat = 0.5,
  shadowOffset: CGPoint = .zero
 ) {
  self.background = background
  self.contentBackground = contentBackground
  self.cornerRadius = cornerRadius
  self.shadowColor = shadowColor
  self.shadowRadius = shadowRadius
  self.shadowOffset = shadowOffset
 }
}
