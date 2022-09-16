#if os(iOS)
 import SwiftUI

 open class FeedbackController {
  public static let shared = FeedbackController()
  public let impact = Haptic()
  public let sound = Sound()
  public let selection = UISelectionFeedbackGenerator()
 }

 extension FeedbackController {
  open class Haptic {
   public let light = UIImpactFeedbackGenerator(style: .light)
   public let medium = UIImpactFeedbackGenerator(style: .medium)
   public let rigid = UIImpactFeedbackGenerator(style: .rigid)
   public let soft = UIImpactFeedbackGenerator(style: .soft)
   public let heavy = UIImpactFeedbackGenerator(style: .heavy)
  }

  open class Sound {}
 }

 struct ImpactModifier<Value: Equatable>: ViewModifier {
  @State var oldValue: Value?
  let value: Value?
  let toggle: Bool
  let condition: ((Value?) -> Bool)?
  let style: KeyPath<FeedbackController.Haptic, UIImpactFeedbackGenerator>
  let intensity: CGFloat
  let action: (() -> ())?
  @ViewBuilder public func body(content: Content) -> some View {
   content.onChange(of: value) { newValue in
    guard
     condition?(newValue) ?? true, toggle || newValue != oldValue
    else { return }
    FeedbackController.shared.impact[keyPath: style]
     .impactOccurred(intensity: intensity)
    action?()
    oldValue = value
   }
  }
 }

 public extension View {
  @_transparent
  func selectionFeedback<SelectionValue>(
   with selection: SelectionValue
  ) -> some View
  where SelectionValue: Equatable & Hashable {
   onChange(of: selection) { _ in
    FeedbackController.shared.selection.selectionChanged()
   }
  }

  @_transparent
  @ViewBuilder func selectionFeedback<Value>(
   _ value: Value,
   when condition: ((Value) -> Bool)? = .none,
   toggle: Bool = false,
   perform action: (() -> ())? = .none
  ) -> some View where Value: Equatable {
   onChange(of: value) { newValue in
    guard
     condition?(newValue) ?? true, toggle || newValue == value
    else { return }
    FeedbackController.shared.selection.selectionChanged()
    action?()
   }
  }

  func impact<Value>(
   _ value: Value?,
   when condition: ((Value?) -> Bool)? = .none,
   toggle: Bool = false,
   _ style: KeyPath<FeedbackController.Haptic, UIImpactFeedbackGenerator>,
   intensity: CGFloat = 1,
   perform action: (() -> ())? = .none
  ) -> some View where Value: Equatable {
   modifier(
    ImpactModifier(
     value: value,
     toggle: toggle,
     condition: condition,
     style: style,
     intensity: intensity,
     action: action
    )
   )
  }
 }
#endif
