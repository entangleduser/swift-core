import SwiftUI

public protocol RowStyle {
 typealias Content = TableRow
 associatedtype ModifiedRow: View
 func body(content: Content) -> ModifiedRow
}

public extension TableRow {
 func rowStyle<S>(_ style: S) -> some View where S: RowStyle {
  style.body(content: self)
 }
}
