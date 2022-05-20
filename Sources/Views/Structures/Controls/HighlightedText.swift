import SwiftUI

#if os(macOS)
 public typealias TextLabel = NSTextField
public typealias FontDescriptor = NSFontDescriptor
#elseif os(iOS)
 public typealias TextLabel = UILabel
public typealias FontDescriptor = UIFontDescriptor
#endif

public enum HighlightStyle {
 case descriptor(FontDescriptor), color(Color?, Color?)
 public var foreground: Color? {
  switch self {
  case let .color(_, foreground):
   return foreground
  default: return .label
  }
 }

 public var background: Color? {
  switch self {
  case let .color(background, _):
   return background
  default: return .none
  }
 }
}

@available(macOS 11, *)
public struct HighlightedText: ViewRepresentable {
 public let text: String
 public let ranges: [NSValue]
 public var font: NativeFont = .systemFont(ofSize: 13)
 public var foreground: Color = .label
 public var style: HighlightStyle = .color(nil, .accentColor)
 public var lineLimit: Int = 4
 public var shouldHighlight: Bool = true
 let lock: NSRecursiveLock = .init()
 public func makeView(context _: Context) -> TextLabel {
  let label: TextLabel = .init()
  #if os(macOS)
   label.maximumNumberOfLines = lineLimit
   label.stringValue = text
  #elseif os(iOS)
   label.text = text
  #endif
  label.lineBreakMode = .byWordWrapping
  label.font = font
  label.textColor = foreground.nativeColor
  highlight(label)
  return label
 }

 #if os(macOS)
  public typealias NSViewType = TextLabel
  public func makeNSView(context: Context) -> TextLabel {
   makeView(context: context)
  }

  public func updateNSView(_ nsView: TextLabel, context _: Context) {
   updateAttributes(nsView)
  }

 #elseif os(iOS)
  public typealias UIViewType = TextLabel

  public func makeUIView(context: Context) -> TextLabel {
   makeView(context: context)
  }

  public func updateUIView(_ uiView: TextLabel, context _: Context) {
   updateAttributes(uiView)
  }
 #endif
}

@available(macOS 11, *)
public extension HighlightedText {
 func highlight(_ label: TextLabel) {
  updateAttributes(label)
  guard shouldHighlight else { return }
  #if os(macOS)
   let text = label.stringValue
  #elseif os(iOS)
   guard let text = label.text else { return }
  #endif
  let ranges: [NSRange] = ranges.map(\.rangeValue)
  let string = NSMutableAttributedString(string: text)
  let foreground = foreground.nativeColor
  var attributes: [NSAttributedString.Key: Any] =
   [.font: font]
  DispatchQueue.main.async { [weak string] in
   guard let string = string else { return }
   if let range = NSRange(text) {
    string.addAttributes(
     [.foregroundColor: foreground, .font: font], range: range
    )
   }
   if let highlightForeground = style.foreground?.nativeColor {
    attributes[.foregroundColor] = highlightForeground
   }
   if let highlightBackground = style.background?.nativeColor {
    attributes[.backgroundColor] = highlightBackground
   }
   DispatchQueue.main.async { [weak string] in
    DispatchQueue.concurrentPerform(iterations: ranges.count) { [weak string] i in
     guard let string = string else { return }
     lock.lock()
     string.addAttributes(attributes, range: ranges[i])
     lock.unlock()
    }
   }
   #if os(macOS)
    label.attributedStringValue = string
   #elseif os(iOS)
    label.attributedText = string
   #endif
  }
 }

 func updateAttributes(_ label: TextLabel) {
  #if os(macOS)
  #elseif os(iOS)
  #endif
  label.backgroundColor = .clear
 }
}
