import SwiftUI

@available(macOS 11.0, *)
public struct EmailLink: View {
 public init?(address: String? = nil, subject: String? = nil) {
  guard let address = address else {
   return nil
  }
  self.address = address
  self.subject = subject
 }

 public var address: String?
 public var subject: String?
 public var body: some View {
  HStack {
   Text("Email").bold().foregroundColor(.label.faded)
   Image(systemName: "envelope.fill")
   if let address = address {
    let formatted =
     "mailto:\(address)" +
     (subject == nil ? .empty : "?subject=\(subject!)")
    if let url = URL(string: formatted) {
     Link(address, destination: url)
    }
   } else {
    Text("Email address not set.")
   }
  }
 }
}
