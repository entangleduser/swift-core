import SwiftUI

struct GeometryModifier: ViewModifier {
 @Binding var proxy: GeometryProxy?
 func body(content: Content) -> some View {
  content.overlay(
   geometryCallback(Color.clear) { self.proxy = $0 }
  )
 }
}

struct SizeModifier: ViewModifier {
 @Binding var size: CGSize
 func body(content: Content) -> some View {
  content.overlay(
   geometryCallback(Color.clear) { self.size = $0.size }
  )
 }
}

struct FrameModifier: ViewModifier {
 @Binding var frame: CGRect
 let coordinateSpace: CoordinateSpace
 func body(content: Content) -> some View {
  content.overlay(
   geometryCallback(Color.clear) {
    self.frame = $0.frame(in: coordinateSpace)
   }
  )
 }
}

public extension ViewModifier {
 @ViewBuilder func geometryCallback<Placeholder: View>(
  _ placeholder: Placeholder,
  _ closure: @escaping (GeometryProxy) -> ()
 ) -> GeometryReader<Placeholder> {
  GeometryReader { proxy in
   placeholder.async { closure(proxy) }
  }
 }
}

public extension View {
 @ViewBuilder func readGeometry(_ proxy: Binding<GeometryProxy?>) -> some View {
  modifier(GeometryModifier(proxy: proxy))
 }

 @ViewBuilder func readSize(_ size: Binding<CGSize>) -> some View {
  modifier(SizeModifier(size: size))
 }

 @ViewBuilder func readFrame(
  _ frame: Binding<CGRect>,
  in coordinateSpace: CoordinateSpace = .global
 ) -> some View {
  modifier(FrameModifier(frame: frame, coordinateSpace: coordinateSpace))
 }
}
