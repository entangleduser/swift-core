import SwiftUI
#if os(iOS)
 public typealias TextFieldDelegate = UITextFieldDelegate
#elseif os(macOS)
 public typealias TextFieldDelegate = NSTextFieldDelegate
#endif
public struct TextView: ViewRepresentable {
 var placeholder: String?
 @Binding var text: String
 @Binding var isFocused: Bool
 var onFocusChange: ((Bool) -> ())?
 var onEditingChanged: ((Bool) -> ())?
 var onCommit: (() -> ())?
 var configuration: ((NativeTextField) -> ())?
 init(
  _ placeholder: String? = .none,
  text: Binding<String>,
  isFocused: Binding<Bool>,
  onFocusChange: ((Bool) -> ())? = .none,
  onEditingChanged: ((Bool) -> ())? = .none,
  onCommit: (() -> ())? = .none,
  configuration: ((NativeTextField) -> ())? = .none
 ) {
  self.configuration = configuration
  self.placeholder = placeholder
  _text = text
  _isFocused = isFocused
  self.onFocusChange = onFocusChange
  self.onEditingChanged = onEditingChanged
  self.onCommit = onCommit
 }

 public func makeView(
  context: Context, handler: ((NativeTextField) -> ())? = .none
 ) -> NativeTextField {
  let view = NativeTextField()
  view.delegate = context.coordinator
  configuration?(view)
  handler?(view)
  return view
 }

 public func updateView(_ view: NativeTextField, context _: Context) {
  if isFocused { view.becomeFirstResponder() }
  else { view.resignFirstResponder() }
 }

 #if os(iOS)
  public func makeUIView(context: Context) -> NativeTextField {
   makeView(context: context) { view in
//   view.addTarget(
//    context.coordinator,
//    action: #selector(Coordinator.textViewDidChange),
//    for: .editingChanged
//   )
    view.placeholder = placeholder
   }
  }

  public func updateUIView(_ view: NativeTextField, context: Context) {
   // view.text = text
   // text = view.text.unwrapped
   if view.text.unwrapped != text {
    text = view.text.unwrapped
   }
   updateView(view, context: context)
  }

 #elseif os(macOS)
  public func makeNSView(context: Context) -> NativeTextField {
   makeView(context: context) { view in
    view.placeholderString = placeholder
   }
  }

  public func updateNSView(_ view: NativeTextField, context: Context) {
   view.stringValue = text
   updateView(view, context: context)
  }
 #endif
 public func makeCoordinator() -> Coordinator {
  Coordinator(
   $text,
   isFocused: $isFocused,
   onFocusChange: onFocusChange,
   onEditingChanged: onEditingChanged,
   onCommit: onCommit
  )
 }

 open class Coordinator: NSObject, TextFieldDelegate {
  @Binding var text: String
  var isFocused: Binding<Bool>
  var onFocusChange: ((Bool) -> ())?
  var onEditingChanged: ((Bool) -> ())?
  var onCommit: (() -> ())?
  init(
   _ text: Binding<String>,
   isFocused: Binding<Bool>,
   onFocusChange: ((Bool) -> ())?,
   onEditingChanged: ((Bool) -> ())?,
   onCommit: (() -> ())?
  ) {
   _text = text
   self.isFocused = isFocused
   self.onFocusChange = onFocusChange
   self.onEditingChanged = onEditingChanged
   self.onCommit = onCommit
  }

  public func textViewDidChange(_ textField: NativeTextField) {
   #if os(macOS)
    text = textField.stringValue
   #endif
   onEditingChanged?(false)
  }

  public func textFieldDidBeginEditing(_: NativeTextField) {
   onEditingChanged?(true)
   isFocused.wrappedValue = true
   if let onFocusChange = onFocusChange {
    DispatchQueue.main.async { onFocusChange(true) }
   }
  }

  public func textFieldDidEndEditing(_: NativeTextField) {
   isFocused.wrappedValue = false
   if let onFocusChange = onFocusChange {
    DispatchQueue.main.async { onFocusChange(false) }
   }
  }

  #if os(iOS)
   public func textFieldDidEndEditing(
    _: NativeTextField,
    reason: NativeTextField.DidEndEditingReason
   ) {
    isFocused.wrappedValue = false
    if let onFocusChange = onFocusChange {
     DispatchQueue.main.async { onFocusChange(false) }
    }
    if reason == .committed {
     if let onCommit = onCommit {
      DispatchQueue.main.async { onCommit() }
     }
    }
   }

   public func textFieldShouldReturn(_: NativeTextField) -> Bool {
    isFocused.wrappedValue = false
    if let onFocusChange = onFocusChange {
     DispatchQueue.main.async { onFocusChange(false) }
    }
    if let onCommit = onCommit {
     DispatchQueue.main.async { onCommit() }
    }
    return true
   }

  #elseif os(macOS)
   public func controlTextDidChange(_ obj: AppKit.Notification) {
    guard let textField = obj.object as? NativeTextField else { return }
    textViewDidChange(textField)
   }

   public func controlTextDidBeginEditing(_ obj: AppKit.Notification) {
    guard let textField = obj.object as? NativeTextField else { return }
    textFieldDidBeginEditing(textField)
   }

   public func controlTextDidEndEditing(_ obj: AppKit.Notification) {
    guard let textField = obj.object as? NativeTextField else { return }
    textFieldDidEndEditing(textField)
   }
  #endif
 }
}
