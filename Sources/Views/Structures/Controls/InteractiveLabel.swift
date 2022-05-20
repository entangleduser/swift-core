import SwiftUI

@available(macOS 11, *)
public struct InteractiveLabel: ViewRepresentable {
 public let text: String
 public var font: NativeFont = .systemFont(ofSize: 15)
 public var foreground: Color = .label
 public var lineLimit: Int = 4
 public var minimumScaleFactor: CGFloat = 0.8
 public func makeView(context _: Context) -> TextLabel {
  let label: TextLabel = .init()
  #if os(macOS)
   label.maximumNumberOfLines = lineLimit
   label.stringValue = text
  #elseif os(iOS)
   label.text = text
  label.isUserInteractionEnabled = true
  label.minimumScaleFactor = minimumScaleFactor
  #endif
  label.lineBreakMode = .byWordWrapping
  label.font = font
  label.textColor = foreground.nativeColor
  return label
 }

 #if os(macOS)
  public typealias NSViewType = TextLabel
 public func makeNSView(context: Context) -> TextLabel {
   makeView(context: context)
  }

  public func updateNSView(_: TextLabel, context _: Context) {}

 #elseif os(iOS)
  public typealias UIViewType = TextLabel

  public func makeUIView(context: Context) -> TextLabel {
   makeView(context: context)
  }

  public func updateUIView(_: TextLabel, context _: Context) {}
 #endif
}
