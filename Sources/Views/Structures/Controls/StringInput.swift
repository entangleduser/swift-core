import SwiftUI
#if os(iOS)
public typealias NativeTextField = UITextField
#elseif os(macOS)
public typealias NativeTextField = NSTextField
#endif
@available(macOS 11.0, *)
public struct StringInput<Entry>: View
where Entry: InfallibleEntry, Entry.Value == String {
 var placeholder: String?
 @Binding var entry: Entry.Value?
 let assignNext: Bool
 let commitOnChange: Bool
 var onSuccess: ((Entry.Value, Self) -> Void)?
 let commitOnSuccess: Bool
 var transformSuccess: ((Entry.Value) -> Entry.Value)?
 var onError: ((Entry.Error) -> Void)?
 let resetOnError: Bool
 var configuration: ((NativeTextField) -> Void)?
 @State var input: Entry.Value = .defaultValue

 var inputView: some View {
  TextField(
   placeholder ?? Entry.placeholder,
   text: $input,
   onEditingChanged: { started in
    guard input.count >= Entry.minLength else { return }
    if !started, commitOnChange { onCommit() }
   },
   onCommit: {
    if !commitOnChange { onCommit() }
   }
  )
 }

 public var body: some View {
  inputView
  #if os(iOS)
   .keyboardType(Entry.keyboardType)
  #endif
   .textContentType(Entry.contentType)
   .onAppear { reset() }
 }

 public init(
  _ placeholder: String? = .none,
  entry: Binding<Entry.Value?>,
  isFocused _: Binding<Bool>? = .none,
  assignNext: Bool = true,
  commitOnChange: Bool = false,
  onSuccess: ((Entry.Value, Self) -> Void)? = .none,
  commitOnSuccess: Bool = true,
  transformSuccess: ((Entry.Value) -> Entry.Value)? = .none,
  onError: ((Entry.Error) -> Void)? = .none,
  resetOnError: Bool = true,
  configuration: ((NativeTextField) -> Void)? = .none
 ) {
  self.placeholder = placeholder
  _entry = entry
  self.assignNext = assignNext
  self.commitOnChange = commitOnChange
  input = entry.wrappedValue.unwrapped
  self.onSuccess = onSuccess
  self.commitOnSuccess = commitOnSuccess
  self.transformSuccess = transformSuccess
  self.onError = onError
  self.resetOnError = resetOnError
  self.configuration = configuration
 }
}

@available(macOS 11.0, *)
public extension StringInput {
 func reset() { input = entry.unwrapped }
 func onCommit() {
  if let transform = Entry.transform(input) {
   input = transform
  }
  guard entry != input else { return }
  switch Entry.valid(input) {
  case var .success(entry):
   if let transform = transformSuccess?(entry) {
    entry = transform
   }
   if commitOnSuccess {
    self.entry = entry
    input = entry
   }
   if let onSuccess = onSuccess {
    onSuccess(entry, self)
   } else { input = entry }
   if assignNext {
    assignNextResponder()
   }
  case let .failure(error):
   if let onError = onError { onError(error) }
   if resetOnError {
    reset()
   }
  }
 }
}
