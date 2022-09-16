//import SwiftUI
//
//@available(macOS 11.0, *)
//public struct CalloutView<Content: View, Detail: View>: View {
// @State var isPresented: Bool = false
// var content: Content
// @ViewBuilder var detail: () -> Detail
// @State var offset: CGFloat = 0
// public var body: some View {
//  GeometryReader {
//   let offset = $0.frame(in: .local).height
//   content
//    .frame(height: offset, alignment: .center)
//    .onAppear {
//     self.offset = offset
//    }
//    .overlay {
//     detail()
//      .padding()
//      .zIndex(.infinity)
//      .background {
//       VStack(alignment: .center, spacing: 0) {
//        Group {
//         Color.background
//          .outline(cornerRadius: 8, width: 1)
//          .cornerRadius(8)
//          .outline(color: .black, cornerRadius: 8)
//         Color.background
//          .frame(width: 11.5, height: 8)
//          .contentShape(Triangle())
//          .mask(Triangle())
//          .rotationEffect(.degrees(180))
//        }
//        #if os(iOS)
//        .background(Color.clear.blurEffect(.systemThickMaterialDark))
//        #endif
//       }
//      }
//      .offset(y: -offset)
//      .opacity(isPresented ? 1 : 0)
//      .transition(.slide.combined(with: .opacity))
//    }
//  }
//  .onTapGesture {
//   animation { isPresented.toggle() }
//  }
// }
//}
//
//@available(macOS 11.0, *)
//public extension View {
// func callout<Content: View>(@ViewBuilder _ detail: @escaping () -> Content) -> some View {
//  CalloutView(content: self, detail: detail)
// }
//}
