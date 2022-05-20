// public struct SecureInput<Entry>: View
//	where Entry: InfallibleEntry, Entry.Value == String {
//	var placeholder: String?
//	@Binding var entry: Entry.Value?
//	let onReturn: ((Entry.Value) -> Void)?
//	let commitOnChange: Bool
//	var onSuccess: ((Entry.Value, Self) -> Void)?
//	let commitOnSuccess: Bool
//	var transformSuccess: ((Entry.Value) -> Entry.Value)?
//	var onError: ((Entry.Error) -> Void)?
//	let resetOnError: Bool
//	var configuration: ((NativeTextField) -> Void)?
//	@State var input: Entry.Value = .defaultValue
//
//	var body: some View {
//		SecureField(
//			placeholder ?? Entry.placeholder,
//			text: $input,
//			onCommit: {
//				onCommit()
//				onReturn?(input)
//			}
//		)
//		.onChange(of: input) { _ in
//			if commitOnChange { onCommit() }
//		}
//	}
//
//	init(
//		_ placeholder: String? = .none,
//		entry: Binding<Entry.Value?>,
//		onReturn: ((Entry.Value) -> Void)? = .none,
//		commitOnChange: Bool = false,
//		onSuccess: ((Entry.Value, Self) -> Void)? = .none,
//		commitOnSuccess: Bool = true,
//		transformSuccess: ((Entry.Value) -> Entry.Value)? = .none,
//		onError: ((Entry.Error) -> Void)? = .none,
//		resetOnError: Bool = true,
//		configuration: ((NativeTextField) -> Void)? = .none
//	) {
//		self.placeholder = placeholder
//		_entry = entry
//		self.onReturn = onReturn
//		self.commitOnChange = commitOnChange
//		input = entry.wrappedValue.unwrapped
//		self.onSuccess = onSuccess
//		self.commitOnSuccess = commitOnSuccess
//		self.transformSuccess = transformSuccess
//		self.onError = onError
//		self.resetOnError = resetOnError
//		self.configuration = configuration
//	}
// }
//
// public extension SecureInput {
//	func reset() { input = entry.unwrapped }
//	func onCommit() {
//		if let transform = Entry.transform(input) {
//			input = transform
//		}
//		guard input.count > entry?.count ?? 0, input.count >= Entry.minLength
//		else { return }
//		switch Entry.valid(input) {
//		case var .success(entry):
//			if let transform = transformSuccess?(entry) {
//				entry = transform
//			}
//			if commitOnSuccess {
//				self.entry = entry
//				input = entry
//			}
//			if let onSuccess = onSuccess {
//				onSuccess(entry, self)
//			} else { input = entry }
//		case let .failure(error):
//			if let onError = onError { onError(error) }
//			if resetOnError {
//				reset()
//			}
//		}
//	}
// }
