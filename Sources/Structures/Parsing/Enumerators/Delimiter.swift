enum Delimiter: Hashable {
 case comma, newline, space, semicolon, custom(_ string: String)
 func hash(into hasher: inout Hasher) {
  hasher.combine(value)
 }
 var value: Character {
  switch self {
  case .comma: return ","
  case .newline: return "\n"
  case .space: return " "
  case .semicolon: return ";"
  case let .custom(string): return Character(string)
  }
 }
}
