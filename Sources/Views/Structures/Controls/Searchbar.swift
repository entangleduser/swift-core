import SwiftUI

@available(macOS 11.0, *)
public struct Searchbar<Background: View>: View {
 public init(
  _ title: String = "Search ...",
  query: Binding<String>,
  isFocused: Binding<Bool>,
  onFocusChange: ((Bool) -> ())? = nil,
  configuration: ((NativeTextField) -> ())? = .none,
  native: Bool = false,
  onCommit: (() -> ())? = .none,
  background: (() -> Background)? = nil,
  cornerRadius: CGFloat = 11.5,
  shadowColor: Color = .clear

 ) {
  self.title = title
  _query = query
  _isFocused = isFocused
  self.onFocusChange = onFocusChange
  self.configuration = configuration
  self.native = native || onCommit != nil
  if let onCommit = onCommit {
   self.onCommit = onCommit
  }
  self.background = background
  self.cornerRadius = cornerRadius
  self.shadowColor = shadowColor
 }

 public var title: String = "Search ..."
 @Binding public var query: String
 @Binding public var isFocused: Bool
 public var onFocusChange: ((_ focused: Bool) -> ())?
 var configuration: ((NativeTextField) -> ())?
 let native: Bool
 var onCommit: (() -> ())?
 public var background: (() -> Background)?
 public var cornerRadius: CGFloat = 11.5
 public var shadowColor: Color = .clear
 public var body: some View {
  HStack(spacing: 8) {
   Image(systemName: "magnifyingglass")
    .resizable()
    .aspectRatio(1, contentMode: .fit)
    .frame(maxWidth: native ? 15 : 17)
    .padding(.leading, native ? 4.5 : 0)
    .foregroundColor(.label.opacity(0.5))
   Group {
    if native {
     TextField(title, text: $query, onCommit: { onCommit?() })
      .textFieldStyle(PlainTextFieldStyle())
      .font(.system(size: 15))
    } else {
     TextView(
      title,
      text: $query,
      isFocused: $isFocused,
      onFocusChange: onFocusChange,
      configuration: {
       $0.font = .systemFont(ofSize: 15)
       $0.textColor = .secondaryLabel
       configuration?($0)
      }
     )
    }
   }
   .frame(height: native ? 18.5 : 20)
   .overlay(
    SmallCloseButton { query = .empty }
     .visibility(query.notEmpty)
     .allowsHitTesting(query.notEmpty),
    alignment: .trailing
   )
   .inset(.standard, 1)
  }
  .inset(.standard, native ? 4.5 : 8.5)
  .background {
   Group {
    if let background = background {
     background()
    } else {
     Backdrop.tertiary.cornerRadius(cornerRadius)
    }
   }
   .onTap(onEnded: { if !native { isFocused = true } }) {
    $1.opacity($0 ? 0.5 : 1)
   }
  }
  .foregroundColor(.secondaryLabel)
  .backgroundColor(.clear)
  .shadow(color: shadowColor, radius: 4.5)
 }
}

@available(macOS 11.0, *)
public extension Searchbar where Background == Color {
 init(
  _ title: String? = .none,
  query: Binding<String>,
  isFocused: Binding<Bool> = .constant(false),
  onFocusChange: ((Bool) -> ())? = .none,
  native: Bool = false,
  onCommit: (() -> ())? = .none,
  background color: Background? = .none,
  cornerRadius: CGFloat? = .none,
  shadowColor: Color? = .none
 ) {
  if let title = title {
   self.title = title
  }
  _query = query
  _isFocused = isFocused
  if let onFocusChange = onFocusChange {
   self.onFocusChange = onFocusChange
  }
  self.native = native || onCommit != nil
  if let onCommit = onCommit {
   self.onCommit = onCommit
  }
  if let color = color {
   background = { color }
  }
  if let cornerRadius = cornerRadius {
   self.cornerRadius = cornerRadius
  }
  if let shadowColor = shadowColor {
   self.shadowColor = shadowColor
  }
 }
}
