import SwiftUI

@available(macOS 11.0, *)
public struct CopyMenu: View {
 let title: String
 let string: String
 public var body: some View {
  Menu(
   content: {
    Button(
     action: {
      #if os(iOS)
      UIPasteboard.general.string = string
      #elseif os(macOS)
      NSPasteboard.general.setString(string, forType: .string)
      #endif
     },
     label: {
      Label(title, systemImage: "doc.on.clipboard.fill")
     }
    )
   },
   label: {
    Text(string)
     .lineLimit(2)
     .minimumScaleFactor(0.8)
   }
  )
 }
}

@available(macOS 11.0, *)
public extension CopyMenu {
 init(_ title: String, _ string: String) {
  self.title = title
  self.string = string
 }
}
