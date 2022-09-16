import SwiftUI
import Colors

public final class PasswordAgent: ObservableObject {
 public static let shared = PasswordAgent()
 public enum Strength: Int, ExpressibleByNilLiteral {
  case none, weak, okay, good, great
  public var string: String {
   switch self {
    case .none: return .empty
    case .weak: return "weak"
    case .okay: return "okay"
    case .good: return "good"
    case .great: return "great"
   }
  }

  public init(nilLiteral _: ()) {
   self = .none
  }
 }

 public enum Error: LocalizedError {
  case numbers, letters, character, identity, common, linked, excluded
  static let prefix = "Password Error"
  public var errorDescription: String? {
   switch self {
    case .numbers: return "\(Self.prefix): Numbers"
    case .letters: return "\(Self.prefix): Letters"
    case .character: return "\(Self.prefix): Character"
    case .identity: return "\(Self.prefix): Identity"
    case .common: return "\(Self.prefix): Common"
    case .linked: return "\(Self.prefix): Linked"
    case .excluded: return "\(Self.prefix): Excluded"
   }
  }

  public var failureReason: String? {
   switch self {
    case .numbers: return "Missing a number 0-9"
    case .letters: return "Missing a letter"
    case .character: return "Missing a special character"
    case .identity: return "Characters are identical"
    case .common: return "Password is common"
    case .linked: return "Password is linked to credentials"
    case .excluded: return "Password is exclusive"
   }
  }

  public var recoverySuggestion: String? { nil }

  /// Describes the rules when creating a password.
  public var helpAnchor: String? { .empty }

  public var localizedDescription: String {
   switch errorDescription {
    case let .some(message):
     return message.appending(" Reason: ").appending(failureReason ?? .empty)
    default: return "\(Self.self): Unknown"
   }
  }
 }

 public func factor(
  _ input: String,
  names: Set<String> = .empty,
  excluding: Set<String> = .empty
 ) {
  // start with the best possible factors to ensure quality
  // every quality is worth a maximum of 5 points for great
  // 2 being the basic requirement points for weak
  // required: length
  // lowercase & uppercase
  // special characters & numbers
  // uniqueness
  do {
   points = 0
   let count = CGFloat(input.count)
   guard count > 5 else { return }
   guard names.map({ $0.lowercased() })
    .allSatisfy({ input.range(of: $0, options: .caseInsensitive) == nil })
   else { throw Error.linked }
   guard excluding.map({ $0.lowercased() })
    .allSatisfy({ input.range(of: $0, options: .caseInsensitive) == nil })
   else { throw Error.excluded }
   guard !Self.topPasswords.contains(input) else { throw Error.common }
   let uniqueCount = CGFloat(input.uniqued().map { $0 }.count)
   guard uniqueCount > 1 else { throw Error.identity }
   var lowerCaseCount: CGFloat = 0
   var upperCaseCount: CGFloat = 0
   var specialCharactersCount: CGFloat = 0
   var numbersCount: CGFloat = 0
   for char in input {
    if char.isLetter {
     if char.isLowercase {
      lowerCaseCount += 1
     } else if char.isUppercase {
      upperCaseCount += 1
     }
    } else if char.isNumber {
     numbersCount += 1
    } else if #"!@#$%^&*()_-+={[}]|\:;"'<,>.?/ "#.contains(char) {
     specialCharactersCount += 1
    } else {
     throw Error.character
    }
   }
   error = .none
   let alphaCount: CGFloat = lowerCaseCount + upperCaseCount
   guard alphaCount > 0 else { throw Error.letters }
   guard numbersCount > 0 else { throw Error.numbers }
   let caseFactor: CGFloat =
    max(lowerCaseCount, upperCaseCount) / min(lowerCaseCount, upperCaseCount)
   let casePoints: CGFloat =
    (0 ..< count).contains(caseFactor) ?
    ((caseFactor - 0.5) * 10) + (alphaCount * caseFactor) : 0
   points =
    count + (uniqueCount * 0.25)
    + casePoints
    + (specialCharactersCount > 0 ? 5 + (specialCharactersCount * 0.25) : 0)
    + numbersCount
  } catch { self.error = (error as! PasswordAgent.Error) }
 }

 @Published public var points: CGFloat = 0
 @Published public var error: Error?

 public var strength: Strength {
  switch points {
   case 0 ... 6: return nil
   case 6 ... 13: return .weak
   case 13 ... 27: return .okay
   case 27 ... 72: return .good
   default: return .great
  }
 }
}

public struct PasswordMeter: View {
 @StateObject private var agent: PasswordAgent = .shared
 @Binding public var input: String
 public var names: Set<String> = .empty
 public var excluding: Set<String> = .empty
 public var cornerRadius: CGFloat = 4.5
 public var cornerStyle: RoundedCornerStyle = .circular
 public var height: CGFloat = 6
 public var width: CGFloat?
 public var padding: CGFloat = 4.5

 public var backgroundColor: Color = .secondaryBackground
 public var outlineColor: Color = .outline.faded

 public var colors: (
  weak: Color, okay: Color, good: Color, great: Color
 ) = (.yellow, .orange, .green, .teal)

 @Binding public var error: PasswordAgent.Error?
 @Binding public var strength: PasswordAgent.Strength

 @State private var frame: CGRect = .zero

 var barWidth: CGFloat {
  let width = frame.width
  let actualWidth = width == 0 ? .screen.width : width
  return (actualWidth / 4) * CGFloat(agent.strength.rawValue)
 }

 var barColor: Color {
  switch agent.strength {
   case .none: return .clear
   case .weak: return colors.weak
   case .good: return colors.good
   case .okay: return colors.okay
   case .great: return colors.great
  }
 }

 public var body: some View {
  let blendedOutline: Color = outlineColor + barColor
  let isStrong = agent.strength == .great
  let backgroundColor =
   agent.error == .none ? backgroundColor : .red.translucent
  backgroundColor
   .frame(width: width, height: height)
   .readFrame($frame)
   .overlay(.leading) {
    HStack(spacing: 0) {
     barColor.translucent
     blendedOutline.faded
      .remove(isStrong)
      .frame(width: 0.5, height: height, alignment: .leading)
    }
    .remove(agent.strength == nil)
    .frame(width: barWidth + (isStrong ? cornerRadius : 0))
    .transition(.scale)
   }
   .mask(RoundedRectangle(cornerRadius: cornerRadius, style: cornerStyle))
   .outline(color: blendedOutline.translucent, cornerRadius: cornerRadius)
   .transition(.scale)
   .padding(.vertical, padding)
   .padding(.horizontal, padding * 0.33)
   .onChange(of: input) { [unowned agent] input in
    withAnimation { [unowned agent] in
     agent.factor(input, names: names, excluding: excluding)
     self.strength = agent.strength
     self.error = agent.error
    }
   }
 }
}

extension PasswordMeter {
 public init(
  _ input: Binding<String>,
  names: Set<String> = .empty,
  excluding: Set<String> = .empty,
  strength: Binding<PasswordAgent.Strength> = .constant(.none),
  error: Binding<PasswordAgent.Error?> = .constant(.none),
  cornerRadius: CGFloat = 4.5,
  cornerStyle: RoundedCornerStyle = .circular,
  height: CGFloat = 8,
  width: CGFloat? = nil,
  padding: CGFloat = 4.5,
  backgroundColor: Color = .secondaryBackground,
  outlineColor: Color = .outline,
  colors: (
   weak: Color, okay: Color, good: Color, great: Color
  ) = (.yellow, .orange, .green, .teal)
 ) {
  _input = input
  self.names = names
  self.excluding = excluding
  _strength = strength
  _error = error
  self.cornerRadius = cornerRadius
  self.cornerStyle = cornerStyle
  self.height = height
  self.width = width
  self.padding = padding
  self.backgroundColor = backgroundColor
  self.outlineColor = outlineColor
  self.colors = colors
 }
}

import Structures

extension PasswordAgent {
 static let topPasswords: [String] =
  try! JSONDecoder()
  .decode(
   [String].self,
   from:
   try! Bundle.module.url(
    forResource: "insecurepasswords", withExtension: "json"
   )!.data()
  )
}
