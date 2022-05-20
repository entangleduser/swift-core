import SwiftUI

@available(macOS 10.15, iOS 13.0, *)
public protocol StateObservable: ObservableObject {
 var state: PublisherState { get set }
}

@available(macOS 10.15, iOS 13.0, *)
public extension StateObservable {
 var isInitializing: Bool { state == .initialize }
 var isFinalized: Bool { state == .finalize }
 var notFinalized: Bool { !isFinalized }
 var isLoading: Bool { state == .load }
 func update(
  _ state: PublisherState = .change,
  after deadline: DispatchTime = .now(),
  perform: @escaping (Self) throws -> Void
 ) rethrows {
  self.state = .load
  DispatchQueue.main
   .asyncAfter(deadline: deadline) { [unowned self] in
    do {
     try perform(self)
     self.state = state
    } catch { debugPrint(error.localizedDescription) }
   }
 }

 func update(
  state: PublisherState = .change,
  after deadline: DispatchTime = .now(),
  perform: @escaping @autoclosure () throws -> Void
 ) rethrows {
   try update(state, after: deadline, perform: { _ in try perform() })
 }
 
 func update(
  _ state: PublisherState = .change, after deadline: DispatchTime = .now()
 ) {
  update(state, after: deadline) { _ in }
 }
 
 func async(
  after deadline: DispatchTime = .now(),
  perform: @escaping @autoclosure () throws -> Void
 ) rethrows {
  try async(after: deadline, { _ in try perform() })
 }

 func async(
  after deadline: DispatchTime = .now(),
  _ perform: @escaping (Self) throws -> Void
 ) rethrows {
  DispatchQueue.main
   .asyncAfter(deadline: deadline) { [unowned self] in
    do { try perform(self) }
    catch { debugPrint(error.localizedDescription) }
   }
 }

 func background(
  after deadline: DispatchTime = .now(),
  perform: @escaping (Self) throws -> Void
 ) rethrows {
  DispatchQueue.global()
   .asyncAfter(deadline: deadline) { [unowned self] in
    do { try perform(self) }
    catch { debugPrint(error.localizedDescription) }
   }
 }
 func background(
  after deadline: DispatchTime = .now(),
  _ perform: @escaping @autoclosure () throws -> Void
 ) rethrows {
  try background(after: deadline, perform: { _ in try perform() })
 }
}
