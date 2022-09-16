import SwiftUI

@available(macOS 10.15, iOS 13.0, *)
@propertyWrapper
@dynamicMemberLookup
public struct Cache<Value: AutoCodable>:
 SerializedCache & CacheWrapper,
 DynamicProperty//, StateObservable
{
// @Published public var state: PublisherState = .initialize {
//  willSet {
//   if newValue != state,
//      state == .update
//       || state == .load
//       || state == .unload,
//      newValue == .change
//       || newValue == .finalize
//       || newValue == .unload {
//    debugPrint("\(Self.self): State transitioned to \(newValue)")
//    self.objectWillChange.send()
//   }
//  }
// }
//
 public var wrappedValue: [AnyHashable: Value] {
  get {
   do {
    return Dictionary(uniqueKeysWithValues: try Self.objects())
   } catch {
    debugPrint(
     Error<Value>.read(
      description:
      error.localizedDescription
     ).localizedDescription
    )
   }
   return .empty
  }
  nonmutating set {
   do {
    // clear cache if dictionary is empty
    if newValue.isEmpty {
     debugPrint("\(Self.self): Removing \(wrappedValue.count) \(Value.self)s")
     //try update {
      //`self` in
      try self.clear()
     //}
    } else {
     //try update {
      //`self` in
      try Self.subtract(newValue.map { ($0.key, $0.value) })
     //}
    }
   } catch {
    debugPrint(
     Error<Value>.write(
      description:
      error.localizedDescription
     ).localizedDescription
    )
   }
  }
 }
 public subscript<Value>(dynamicMember dynamicMember: ReferenceWritableKeyPath<Cache, Value>) -> Value {
  get { self[keyPath: dynamicMember] }
  nonmutating set { self[keyPath: dynamicMember] = newValue }
 }
// public subscript(
//  dynamicMember dynamicMember: ReferenceWritableKeyPath<Cache, Value>
// ) -> Value {
//  get { wrappedValue }
//  set { wrappedValue[] = newValue }
// }
 @available(macOS 10.15, iOS 13.0, *)
 public var projectedValue: Binding<[AnyHashable: Value]> {
  Binding<[Key: Value]>(
   get: { self.wrappedValue },
   set: { self.wrappedValue = $0 }
  )
 }
 
 public func update() {
//  guard isLoading else { return }
//  update(state)
 }

 public init() {
  //defer { if contents().notEmpty { update(.finalize) } }
 }
}

@available(macOS 10.15, iOS 13.0, *)
public extension Cache {
 /// Intializes a serialized cache that is encapsulated by a property wrapper.
 init(wrappedValue: [Key: Value] = [:]) {
//  self = Self.shared
//  defer { for (key, value) in wrappedValue { self[key] = value } }
  self.init()
 }

 /// An automatically determined name for the cache folder
 /// based on the associated type `Value`.
 static var key: String { String(describing: Value.self) }

 // MARK: - Subscripting

 /// A subscript for looking up and setting a `Value`
 /// that comforms to `AutoCodable` & `Identifiable`.
 /// - parameter id: The object's UUID for decoding and encoding.
 static subscript(_ key: Key) -> Value? {
  get {
   do {
    // read the data from the cache
    if let data = try? getData(fileURL(key.description.description)) {
     // decode the data if valid
     return try Value.decoder.decode(Value.self, from: data)
    }
   } catch {
    debugPrint(
     Error<Value>.read(
      description:
      error.localizedDescription
     ).localizedDescription
    )
   }
   return nil
  }
  set {
   do {
    guard newValue != nil else { // or invalid
     try fileManager.removeItem(at: fileURL(key.description))
     return
    }
    // ensure the file doesn't exist
    guard try !fileExists(fileURL(key.description)) else { return }

    // encode the data
    let data = try Value.encoder.encode(newValue)

    // create the cache if needed
    try Self.folder(createIfNeeded: true)

    // write the data to the cache
    try data.write(to: fileURL(key.description))
   } catch {
    debugPrint(
     Error<Value>.write(
      description: error.localizedDescription
     ).localizedDescription
    )
   }
  }
 }
}

// MARK: - Error-Handling
@available(macOS 10.15, iOS 13.0, *)
extension Cache {
 enum Error<Value>: LocalizedError {
  case read(description: String),
       write(description: String)

  static var prefix: String { "\(Self.self): " }

  var failureReason: String? {
   switch self {
   case let .read(description):
    return description
   case let .write(description):
    return description
   }
  }

  var errorDescription: String? {
   switch self {
   case .read:
    return "Read." + Self.prefix.appending(failureReason!)
   case .write:
    return "Write." + Self.prefix.appending(failureReason!)
   }
  }
 }
}
