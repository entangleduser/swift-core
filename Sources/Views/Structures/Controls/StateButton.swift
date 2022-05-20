import SwiftUI
import Core

#if os(iOS)
 public typealias Control = UIControl
#elseif os(macOS)
 public typealias Control = NSControl
 public extension Control {
  enum State: Int, OptionSet, Sequence {
   case normal = 0, focused, highlighted
   public init(rawValue _: Int) { fatalError() }
  }
 }
#endif
extension Control.State: Infallible {
 public static let defaultValue: Self = .normal
 /// A boolean value indicating when a control is pressed down.
 @_transparent public var isFocused: Bool { contains(.focused) }
 /// A boolean value indicating when a control is active and focused.
 @_transparent public var isHighlighted: Bool { contains(.highlighted) }
 @_transparent public var isHighlightedAndFocused: Bool {
  symmetricDifference([.focused, .highlighted]).isEmpty
 }
}

/// A view modifier used to send button control state to a view.
@available(macOS 11.0, *)
public struct ButtonState: ButtonStyle {
 @Binding var controlState: Control.State
 var onChange: ((Control.State) -> ())?
 @ViewBuilder
 public func makeBody(configuration: Configuration) -> some View {
  configuration.label
   .onChange(of: configuration.isPressed) { isPressed in
    DispatchQueue.main.async {
     let state: Control.State = isPressed ? .focused : .normal
     onChange?(state)
     controlState = state
    }
   }
 }
}

/// A button that reads the `UIControl.State` of the control view.
@available(macOS 11.0, *)
public struct StateButton<Label>: View where Label: View {
 @State var controlState: Control.State = .defaultValue
 var action: ((Control.State) -> ())?
 var onChange: ((Control.State) -> ())?
 var label: ((_ willChange: Control.State) -> Label)?
 public var body: some View {
  Button(
   action: { action?(controlState) },
   label: { label?(controlState) }
  )
  .buttonStyle(
   ButtonState(controlState: $controlState, onChange: onChange)
  )
 }
}

@available(macOS 11.0, *)
public extension StateButton {
 init(
  action: ((Control.State) -> ())? = .none,
  onChange: ((Control.State) -> ())? = .none,
  @ViewBuilder label: @escaping (_ state: Control.State) -> Label
 ) {
  self.action = action
  self.onChange = onChange
  self.label = label
 }
 init(
  action: (() -> ())? = .none,
  onChange: ((Control.State) -> ())? = .none,
  @ViewBuilder label: @escaping (_ state: Control.State) -> Label
 ) {
  self.action = { _ in action?() }
  self.onChange = onChange
  self.label = label
 }
}
