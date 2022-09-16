import SwiftUI
open class OrientationManager: NSObject, ObservableObject {
 static let shared = OrientationManager()
 @Published public var deviceOrientation: UIDeviceOrientation =
 UIDevice.current.orientation
 @objc func didChangeOrientation(_ notification: NSNotification) {
  deviceOrientation = UIDevice.current.orientation
 }
 deinit {
  NotificationCenter.default.removeObserver(self)
 }
 public override init() {
  super.init()
  NotificationCenter.default.addObserver(
   self,
   selector: #selector(didChangeOrientation),
   name: UIDevice.orientationDidChangeNotification, object: nil
  )
 }
}

public struct DeviceOrientationKey: EnvironmentKey {
 public static let defaultValue =
 OrientationManager.shared.deviceOrientation
 public init() {}
}

public extension EnvironmentValues {
 var deviceOrientation: UIDeviceOrientation {
  self[DeviceOrientationKey.self]
 }
}

