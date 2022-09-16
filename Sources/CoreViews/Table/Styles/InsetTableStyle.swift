import SwiftUI

@available(macOS 11.0, *)
@available(macOS 11.0, *)
public struct InsetTableStyle: TableStyle {
 private let background: Color
 private let contentBackground: Color
 private let cornerRadius: CGFloat
 private let shadowColor: Color
 private let shadowRadius: CGFloat
 private let shadowOffset: CGPoint
 private let showsLine: Bool

 public func body(content: Body) -> some View {
  content
   .modifier(BorderModifier(showsLine: showsLine))
 }

 public func content(content: Content) -> some View {
  content
   .contentStyle(
    InsetTableContentStyle(
     background,
     contentBackground: contentBackground,
     cornerRadius: cornerRadius,
     shadowColor: shadowColor,
     shadowRadius: shadowRadius,
     shadowOffset: shadowOffset
    )
   )
 }

 public func row(content: Row) -> some View {
  content
   .rowStyle(DefaultRowStyle())
 }

 public init(
  _ background: Color = .groupedBackground,
  contentBackground: Color = .background,
  cornerRadius: CGFloat = 15,
  shadowColor: Color = .secondaryLabel,
  shadowRadius: CGFloat = 0.5,
  shadowOffset: CGPoint = .zero,
  showsLine: Bool = false
 ) {
  self.background = background
  self.contentBackground = contentBackground
  self.cornerRadius = cornerRadius
  self.shadowColor = shadowColor
  self.shadowRadius = shadowRadius
  self.shadowOffset = shadowOffset
  self.showsLine = showsLine
 }
}
