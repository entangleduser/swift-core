import struct Foundation.CharacterSet
public extension Character {
 var isAlphaNumeric: Bool {
  guard let scalar = unicodeScalars.first else { return false }
  return CharacterSet.alphanumerics.contains(scalar)
 }
}
