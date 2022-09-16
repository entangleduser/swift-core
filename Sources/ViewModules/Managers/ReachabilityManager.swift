import SwiftUI

/// Reachability class intended to be subclassed by an AppDelegate.
open class ReachabilityManager: NSObject, ObservableObject {
 static let shared = ReachabilityManager()
 let reachability = try! Reachability(hostname: "www.google.com")
 @Published public var networkStatus: Reachability.Connection = .unknown {
  didSet {
   if oldValue != .unknown {
    reachabilityUpdated()
   }
  }
 }

 public var offline: Bool { networkStatus == .unavailable }
 @objc func reachabilityChanged(_: NSNotification) {
  networkStatus = reachability.connection
 }

 open func reachabilityUpdated() {}
 override public init() {
  super.init()
  NotificationCenter.default
   .addObserver(
    self,
    selector: #selector(reachabilityChanged(_:)),
    name: .reachabilityChanged,
    object: nil
   )
  do {
   try reachability.startNotifier()
  } catch {
   debugPrint(error.localizedDescription)
  }
 }

 public enum ConnectionError: LocalizedError {
  case reachability(_ status: Reachability.Connection)
  public var failureReason: String? {
   switch self {
   case let .reachability(connection) where connection == .unavailable:
    return "Your connection was lost!"
   default: return .empty
   }
  }
 }
}

public struct ReachabilityKey: EnvironmentKey {
 public static let defaultValue = ReachabilityManager.shared.networkStatus
 public init() {}
}

public extension EnvironmentValues {
 var reachability: Reachability.Connection {
  self[ReachabilityKey.self]
 }
}
