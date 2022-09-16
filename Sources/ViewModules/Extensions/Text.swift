import SwiftUI

// TODO: Implement more in text based views.
public extension Text {
 struct Optional: View {
  private let text: Text
  public var body: some View { text }
  public init?(_ text: String?) {
   guard let text = text else { return nil }
   self.text = Text(text)
  }
 }
}


