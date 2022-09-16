import SwiftUI

public protocol ListView: View {
 var content: TableContent { get set }
 var axis: Axis.Set { get set }
 var showsIndicators: Bool { get set }
}
