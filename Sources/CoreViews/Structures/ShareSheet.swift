#if os(iOS)
import SwiftUI

public struct ShareSheet: UIViewControllerRepresentable {
 let items: [Any]
 let services: [UIActivity]?
 public func makeUIViewController(context _: Context) -> UIActivityViewController {
  UIActivityViewController(
   activityItems: items,
   applicationActivities: services
  )
 }

 public func updateUIViewController(_: UIViewControllerType, context _: Context) {}
}

public extension View {
 @ViewBuilder
 func shareSheet(
  isPresented: Binding<Bool>,
  items: [Any] = .empty,
  services: [UIActivity]? = .none,
  onCompletion perform: @escaping () -> Void = {}
 ) -> some View {
  sheet(
   isPresented: isPresented,
   content: { ShareSheet(items: items, services: services) }
  )
   .onDisappear(
    perform: {
     isPresented.wrappedValue = false
     perform()
    }
   )
 }
}
#endif
