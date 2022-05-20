#if os(iOS)
 import AVFoundation
 import Storage
 import SwiftUI

public protocol CameraCoordinator: DefaultCameraCoordinator {}
public struct CameraView: UIViewRepresentable {
 public typealias Coordinator = DefaultCameraCoordinator
  public var coordinator: DefaultCameraCoordinator
  public var preset: AVCaptureSession.Preset
 public var gravity: AVLayerVideoGravity
  public var onBuffer: ((CMSampleBuffer) -> ())?
  public var configuration: (() -> ())?
  public var onCapture: ((UIImage) -> ())?
  public init(
   _ preset: AVCaptureSession.Preset = .high,
   gravity: AVLayerVideoGravity = .resizeAspect,
   coordinator: DefaultCameraCoordinator = .default,
   configuration: (() -> ())? = .none,
   onBuffer: ((CMSampleBuffer) -> ())? = .none,
   onCapture: ((UIImage) -> ())? = .none
  ) {
   self.preset = preset
   self.gravity = gravity
   self.coordinator = coordinator
   self.configuration = configuration
   self.onCapture = onCapture
   self.onBuffer = onBuffer
  }

  public func makeCoordinator() -> DefaultCameraCoordinator { coordinator }
  public func makeUIView(context: Context) -> UIView {
   context.coordinator.onCapture = onCapture
   context.coordinator.preset = preset
   context.coordinator.gravity = gravity
   context.coordinator.configuration = configuration
   context.coordinator.onBuffer = onBuffer
   return context.coordinator.setupPreview()
  }

  public func updateUIView(_: UIView, context: Context) {
   context.coordinator.updateHost()
  }
 }


 extension AVCaptureDevice.FlashMode: CaseIterable {
  public static let allCases: [AVCaptureDevice.FlashMode] = [.off, .on, .auto]
 }

 extension AVCaptureDevice.TorchMode: CaseIterable, CustomStringConvertible {
  public static let allCases: [AVCaptureDevice.TorchMode] = [.off, .on]
  public var description: String {
   switch self {
   case .off: return "off"
   case .on: return "on"
   default: fatalError("Torch mode has no description")
   }
  }
 }

 extension AVCaptureDevice.FocusMode: CaseIterable, CustomStringConvertible {
  public static let allCases: [AVCaptureDevice.FocusMode] =
   [.autoFocus, .continuousAutoFocus, .locked]
  public var description: String {
   switch self {
   case .autoFocus: return "auto"
   case .continuousAutoFocus: return "countinous"
   case .locked: return "locked"
   default: fatalError("Focus level has no description")
   }
  }
 }

 public extension UIImage.Orientation {
  var description: String {
   switch self {
   case .left: return "left"
   case .right: return "right"
   default: return "up"
   }
  }
 }

 public extension AVCaptureVideoOrientation {
  var description: String {
   switch self {
   case .landscapeLeft: return "landscapeLeft"
   case .landscapeRight: return "landscapeRight"
   default: return "portrait"
   }
  }
 }

 public extension UIImage {
  /// Fix image orientaton to protrait up
  func fixedOrientation() -> UIImage? {
   guard imageOrientation != UIImage.Orientation.up else {
    // This is default orientation, don't need to do anything
    return copy() as? UIImage
   }

   guard let cgImage = self.cgImage else {
    // CGImage is not available
    return nil
   }

   guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
    return nil // Not able to create CGContext
   }

   var transform = CGAffineTransform.identity

   switch imageOrientation {
   case .down, .downMirrored:
    transform = transform.translatedBy(x: size.width, y: size.height)
    transform = transform.rotated(by: CGFloat.pi)
   case .left, .leftMirrored:
    transform = transform.translatedBy(x: size.width, y: 0)
    transform = transform.rotated(by: CGFloat.pi / 2.0)
   case .right, .rightMirrored:
    transform = transform.translatedBy(x: 0, y: size.height)
    transform = transform.rotated(by: CGFloat.pi / -2.0)
   case .up, .upMirrored:
    break
   @unknown default:
    fatalError("Missing...")
   }

   // Flip image one more time if needed to, this is to prevent flipped image
   switch imageOrientation {
   case .upMirrored, .downMirrored:
    transform = transform.translatedBy(x: size.width, y: 0)
    transform = transform.scaledBy(x: -1, y: 1)
   case .leftMirrored, .rightMirrored:
    transform = transform.translatedBy(x: size.height, y: 0)
    transform = transform.scaledBy(x: -1, y: 1)
   case .up, .down, .left, .right:
    break
   @unknown default:
    fatalError("Missing...")
   }

   ctx.concatenate(transform)

   switch imageOrientation {
   case .left, .leftMirrored, .right, .rightMirrored:
    ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
   default:
    ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
   }

   guard let newCGImage = ctx.makeImage() else { return nil }
   return UIImage(cgImage: newCGImage, scale: 1, orientation: .up)
  }
 }


open class DefaultCameraCoordinator:
 OrientationManager, AVCapturePhotoCaptureDelegate, StateObservable {
 public static let `default` = DefaultCameraCoordinator()
 public static let `buffer` = VideoBufferCoordinator()
 @Published public var shouldCapture = false {
  willSet {
   if !newValue {
    async(after: .now() + 1) { `self` in
     self.shouldCapture = true
    }
   }
  }
 }
 
 @Published public var isVisible: Bool = false
 @Published
 public var state: PublisherState = .initialize {
  willSet {
   if newValue != state,
      state == .load || state == .unload
       || newValue == .change
       || newValue == .finalize {
    debugPrint("Camera State transitioned to \(newValue)")
    objectWillChange.send()
   }
  }
 }
 
 public var currentAngle: Double {
  withAnimation { [unowned self] in
   switch deviceOrientation {
    case .landscapeRight: return -90
    case .landscapeLeft: return 90
    default: return 0
   }
  }
 }
 
 public var orientation: UIImage.Orientation {
  switch currentAngle {
   case -90: return .down
   case 90: return .up
   default: return .right
  }
 }
 
 public var cgImageOrientation: CGImagePropertyOrientation {
  switch deviceOrientation {
   case .portraitUpsideDown: return .left
   case .landscapeLeft: return .upMirrored
   case .landscapeRight: return .down
   case .portrait: return .up
   default: return .up
  }
 }
 
 override func didChangeOrientation(_ notification: NSNotification) {
  super.didChangeOrientation(notification)
  previewLayer?.frame = UIScreen.main.bounds
  previewLayer?.connection?.videoOrientation = videoOrientation
  updateHost()
 }
 
 var videoOrientation: AVCaptureVideoOrientation {
  switch deviceOrientation {
   case .portrait: return .portrait
   case .portraitUpsideDown: return .portraitUpsideDown
   case .landscapeLeft: return .landscapeRight
   case .landscapeRight: return .landscapeLeft
   default: return .portrait
  }
 }
 
 public var settings: AVCapturePhotoSettings = .init()
 @Published public var flashMode: AVCaptureDevice.FlashMode = .auto {
  willSet {
   if settings.flashMode != newValue {
    settings.flashMode = newValue
   }
  }
 }
 
 @Published public var torchMode: AVCaptureDevice.TorchMode = .off {
  willSet {
   if let device = device, device.torchMode != newValue {
    device.torchMode = newValue
   }
  }
 }
 
 @Setting(\.enableShutterSound) public var enableShutterSound
 
 public var preset: AVCaptureSession.Preset = .high
 public var gravity: AVLayerVideoGravity = .resizeAspect
 public var configuration: (() -> ())?
 public var onCapture: ((UIImage) -> ())?
 public var onBuffer: ((CMSampleBuffer) -> ())?
 public let device: AVCaptureDevice? =
 AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) ??
 AVCaptureDevice
  .default(.builtInWideAngleCamera, for: .video, position: .back)
 public let status: AVAuthorizationStatus =
 AVCaptureDevice.authorizationStatus(for: .video)
 public var captureSession = AVCaptureSession()
 public let output = AVCapturePhotoOutput()
 public lazy var connection: AVCaptureConnection? =
 captureSession.connections.first(
  where: { [unowned self] in $0 == self.device }
 )
 
 var previewLayer: AVCaptureVideoPreviewLayer!
 var baseLayer: UIView!
 override public init() {
  super.init()
   previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
  let view = UIView(frame: UIScreen.main.bounds)
  view.backgroundColor = .clear
  view.contentMode = .scaleAspectFill
  self.previewLayer!.videoGravity = gravity
  self.previewLayer!.frame = view.bounds
  view.layer.addSublayer(self.previewLayer!)
  baseLayer = view
 }
 
 public func requestStatus() {
  switch status {
   case .authorized: start()
   case .denied: state = .initialize
    debugPrint("Camera access was denied.")
   default:
    AVCaptureDevice.requestAccess(for: .video, completionHandler: handleRequest)
  }
 }
 
 public func handleRequest(_ authorized: Bool) {
  if authorized { start() }
 }
 
 public func start() {
  guard let device = device, device.position == .back else { return }
  do {
   let input = try AVCaptureDeviceInput(device: device)
   try device.lockForConfiguration()
   captureSession.beginConfiguration()
   if captureSession.canAddInput(input) { captureSession.addInput(input) }
   if captureSession.canAddOutput(output) { captureSession.addOutput(output) }
   configuration?()
   captureSession.sessionPreset = preset
   connection?.videoOrientation = videoOrientation
   settings.flashMode = flashMode
   captureSession.commitConfiguration()
   captureSession.startRunning()
   shouldCapture = true
   device.unlockForConfiguration()
  } catch {
   state = .unload
   debugPrint(error.localizedDescription)
  }
 }
 
 public func stop() {
  state = .unload
  device?.unlockForConfiguration()
  captureSession.stopRunning()
 }
 
 public func capture() {
  guard shouldCapture else { return }
  background { `self` in
   guard self.shouldCapture else { return }
   self.output.capturePhoto(with: self.settings, delegate: self)
   self.async { `self` in self.shouldCapture = false }
  }
 }
 
 func setupPreview() -> UIView {
  update(.finalize) { $0.updateHost() }
  return baseLayer
 }
 
 func updateHost() {
  baseLayer.setNeedsLayout()
  baseLayer.setNeedsDisplay()
 }
 public func photoOutput(
  _: AVCapturePhotoOutput,
  willBeginCaptureFor _: AVCaptureResolvedPhotoSettings
 ) {
  if !enableShutterSound {
   AudioServicesDisposeSystemSoundID(1108)
  }
  settings = .init()
  settings.flashMode = flashMode
 }
 
 public func photoOutput(
  _: AVCapturePhotoOutput,
  didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?
 ) {
  if let error = error { debugPrint(error.localizedDescription) }
  guard
   let cgImage = photo.cgImageRepresentation(),
   let image = UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
    .fixedOrientation()
  else { return }
  onCapture?(image)
 }
}

public class VideoBufferCoordinator: DefaultCameraCoordinator, AVCaptureVideoDataOutputSampleBufferDelegate {
 public var bufferSize: CGSize = .zero
 public let videoDataOutput = AVCaptureVideoDataOutput()
 public let videoDataOutputQueue =
 DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
 public func captureOutput(
  _ output: AVCaptureOutput,
  didDrop sampleBuffer: CMSampleBuffer,
  from connection: AVCaptureConnection
 ) {
  debugPrint("Dropped frame!")
 }
 public func captureOutput(
  _ output: AVCaptureOutput,
  didOutput sampleBuffer: CMSampleBuffer,
  from connection: AVCaptureConnection
 ) {
  onBuffer?(sampleBuffer)
 }
}
#endif
