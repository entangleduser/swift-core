import SwiftUI

@available(macOS 11.0, *)
public struct DetailRow<Content, Hidden>: View where Content: View, Hidden: View {
 var arrowAlignment: Alignment = .topTrailing
 var content: () -> Content
 var hidden: (() -> Hidden)?
 @State var isHidden: Bool = true
 public var body: some View {
  VStack(alignment: .leading) {
   content()
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .padding(.bottom)
    .overlay(
     Group {
      if hidden != nil {
       Image(systemName: isHidden ? "chevron.down" : "chevron.up")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 18.5)
        .padding(.top)
        .foregroundColor(.tertiaryLabel)
      }
     }, alignment: arrowAlignment
    )
    .contentShape(Rectangle())
    .onTapGesture {
     isHidden.toggle()
    }
   if let hidden = hidden {
    hidden()
     .frame(maxWidth: .infinity, maxHeight: isHidden ? 0 : .infinity)
     .contentShape(Rectangle())
   }
  }
 }
}
