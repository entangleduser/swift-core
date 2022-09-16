import SwiftUI
#if os(iOS)
 public typealias NativeTextView = UITextView
 public typealias NativeTextViewDelegate = UITextViewDelegate
#elseif os(macOS)
 public typealias NativeTextView = NSTextView
 public typealias NativeTextViewDelegate = NSTextViewDelegate
#endif

public struct EditorView: ViewRepresentable {
 @Binding var isFocused: Bool
 var placeholder: String?
 @Binding var text: String
 var foreground: Color?
 var size: CGFloat?
 var onEditingChanged: ((Bool) -> ())?
 var onCommit: ((NativeTextView) -> ())?
 var configuration: ((NativeTextView) -> ())?
 public init(
  _ placeholder: String? = .none,
  text: Binding<String>,
  foreground: Color? = .none,
  size: CGFloat? = .none,
  isFocused: Binding<Bool> = .constant(false),
  onEditingChanged: ((Bool) -> ())? = .none,
  onCommit: ((NativeTextView) -> ())? = .none,
  configuration: ((NativeTextView) -> ())? = .none
 ) {
  self.configuration = configuration
  self.placeholder = placeholder
  _text = text
  _isFocused = isFocused
  self.foreground = foreground
  self.size = size
  self.onEditingChanged = onEditingChanged
  self.onCommit = onCommit
 }

 public func makeCoordinator() -> Coordinator {
  Coordinator(
   $text,
   foreground: foreground,
   size: size,
   isFocused: $isFocused,
   onEditingChanged: onEditingChanged,
   onCommit: onCommit
  )
 }

 public func makeView(
  context: Context, handler: ((NativeTextView) -> ())? = .none
 ) -> NativeTextView {
  let view = NativeTextView()
  view.delegate = context.coordinator
  configuration?(view)
  view.font = .systemFont(ofSize: size != nil ? size! : 13)
  if let foreground = foreground {
   view.textColor = foreground.nativeColor
  }
  handler?(view)
  return view
 }

 public func updateView(_ view: NativeTextView, context _: Context) {
  if isFocused { view.becomeFirstResponder() }
  else { view.resignFirstResponder() }
  if let foreground = foreground {
  view.textColor = foreground.nativeColor
  }
  if let size = size {
   view.font = .systemFont(ofSize: size)
  }
 }

 #if os(iOS)
  public func makeUIView(context: Context) -> NativeTextView {
   makeView(context: context) { view in
    view.contentMode = .scaleAspectFit
    view.adjustsFontForContentSizeCategory = true
   }
  }

  public func updateUIView(_ uiView: NativeTextView, context: Context) {
   uiView.text = text
   updateView(uiView, context: context)
  }

 #elseif os(macOS)
  public func makeNSView(context: Context) -> NativeTextView {
   makeView(context: context)
  }

  public func updateNSView(_ nsView: NSTextView, context: Context) {
   nsView.string = text
   updateView(nsView, context: context)
  }
 #endif

 public class Coordinator: NSObject, NativeTextViewDelegate {
  @Binding var text: String
  var isFocused: Binding<Bool>
  var onEditingChanged: ((Bool) -> ())?
  var onCommit: ((NativeTextView) -> ())?
 var foreground: Color?
 var size: CGFloat?
  init(
   _ text: Binding<String>,
   foreground: Color? = .none,
   size: CGFloat? = .none,
   isFocused: Binding<Bool>,
   onEditingChanged: ((Bool) -> ())?,
   onCommit: ((NativeTextView) -> ())?
  ) {
   _text = text
   self.foreground = foreground
   self.size = size
   self.isFocused = isFocused
   self.onEditingChanged = onEditingChanged
   self.onCommit = onCommit
  }

  @objc public func textViewDidChange(_ textView: NativeTextView) {
   #if os(iOS)
    text = textView.text.unwrapped
   #elseif os(macOS)
    text = textView.string
   #endif
   onEditingChanged?(false)
  }

  public func textViewDidBeginEditing(_: NativeTextView) {
   onEditingChanged?(true)
   isFocused.wrappedValue = true
  }

  public func textViewDidEndEditing(_: NativeTextView) {
   isFocused.wrappedValue = false
  }

  func textViewShouldReturn(_ textView: NativeTextView) -> Bool {
   isFocused.wrappedValue = false
   if let onCommit = onCommit {
    DispatchQueue.main.async { [weak textView] in
     guard let textView = textView else { return }
     onCommit(textView)
    }
   }
   return true
  }

  #if os(macOS)
   public func textDidChange(_ obj: AppKit.Notification) {
    guard let textView = obj.object as? NativeTextView else { return }
    textViewDidChange(textView)
   }

   public func textDidBeginEditing(_ obj: AppKit.Notification) {
    guard let textView = obj.object as? NativeTextView else { return }
    textViewDidBeginEditing(textView)
   }

   public func textDidEndEditing(_ obj: AppKit.Notification) {
    guard let textView = obj.object as? NativeTextView else { return }
    textViewDidEndEditing(textView)
   }
  #endif
 }
}
