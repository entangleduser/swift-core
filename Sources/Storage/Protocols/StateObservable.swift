import SwiftUI

@available(macOS 10.15, iOS 13.0, *)
public protocol StateObservable: ObservableObject {
  var state: PublisherState { get set }
}

@available(macOS 10.15, iOS 13.0, *)
public extension StateObservable {
  func update(
    _ state: PublisherState = .change,
    deadline: DispatchTime = .now(),
    _ perform: @escaping () throws -> Void
  ) {
    DispatchQueue.main
      .asyncAfter(deadline: deadline) { [weak self] in
        do {
          try perform()
          self?.state = state
        } catch {
          debugPrint(error.localizedDescription)
        }
      }
  }
}
