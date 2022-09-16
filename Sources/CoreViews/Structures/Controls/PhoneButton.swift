import SwiftUI

@available(macOS 11.0, *)
public struct PhoneButton: View {
 public init?(number: String? = nil) {
  guard let number = number else {
   return nil
  }
  self.number = number
 }

 public var number: String?
 public var body: some View {
  HStack {
   Text("Phone").bold().foregroundColor(.label.faded)
   Image(systemName: "phone.fill")
   if let number = number, !number.isEmpty {
    let formatted =
     "tel://" + number.filter(\.isWholeNumber)
    if let url = URL(string: formatted) {
     Link(number, destination: url)
    }
   } else {
    Text("Phone number not set.")
   }
  }
 }
}
