import SwiftUI

public struct AnyTable: ListView {
 public var content: TableContent
 public var axis: Axis.Set = .vertical
 public var showsIndicators: Bool = true

 public var body: some View {
  ScrollView(axis, showsIndicators: showsIndicators) {
   content
    .frame(maxHeight: .infinity)
  }
 }
}

public extension AnyTable {
 init<T: ListView>(_ table: T, _ content: TableContent) {
  self.content = content
  axis = table.axis
  showsIndicators = table.showsIndicators
 }
}
