import SwiftUI

public struct EmptyPullStyle: PullStyle {
 public func body(content: Content) -> some View {
  content
 }

 public func makeOverlay(config _: Configuration) -> some View {
  EmptyView()
 }

 public init() {}
}
