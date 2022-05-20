import SwiftUI

public extension NativeImage {
 static var logo: NativeImage { NativeImage(named: "Logo") ?? .init() }
}

@available(macOS 11.0, *)
public extension Image {
 init(nativeImage: NativeImage?) {
  self = {
   guard let nativeImage = nativeImage else { return .blank }
   #if os(iOS)
    return Image(uiImage: nativeImage)
   #elseif os(macOS)
    return Image(nsImage: nativeImage)
   #endif
  }()
 }

 init(_ nativeImage: NativeImage?) {
  self.init(nativeImage: nativeImage)
 }
 enum Symbol: String, View {
  case photo = "photo.fill", camera = "camera.fill", avatar = "person.fill"
  public var body: Image {
   Image(systemName: rawValue).resizable()
  }
 }

 struct Placeholder {
  public static let shared = Placeholder()
  public var avatar: Image { .avatar }
  public var photo: Image { .photo }
  public var camera: Image { .camera }
 }

 static var blank: Image { Image(nativeImage: .init()) }
 static var logo: Image { Image(nativeImage: .logo) }
 static var photo: Image { Symbol.photo.body }
 static var avatar: Image { Symbol.avatar.body }
 static var camera: Image { Symbol.camera.body }

 init(_ image: Image?, with placeholder: KeyPath<Image.Placeholder, Image>) {
  self = image ?? Image.Placeholder.shared[keyPath: placeholder]
 }

 init(_ data: Data?) {
  self = {
   guard let data = data,
         let image = NativeImage(data: data) else { return .blank }
   return Image(nativeImage: image)
  }()
 }
}

public extension NativeImage {
 func thumbnail(
  of width: CGFloat,
  with scale: CGFloat = 1 // ,
//  orientation: NativeImage.Orientation? = .none
 ) -> NativeImage? {
  guard let data = pngData(),
        let source = CGImageSourceCreateWithData(data as CFData, nil)
  else {
   return nil
  }
  let options = [
   kCGImageSourceCreateThumbnailWithTransform: true,
   kCGImageSourceCreateThumbnailFromImageAlways: true,
   kCGImageSourceThumbnailMaxPixelSize: width * scale
  ] as CFDictionary
  guard let ref = CGImageSourceCreateThumbnailAtIndex(source, .zero, options)
  else { return nil }
  defer { CGImageSourceRemoveCacheAtIndex(source, .zero) }
  #if os(iOS)
   return NativeImage(cgImage: ref)
  #elseif os(macOS)
   return
    NativeImage(cgImage: ref, size: NSSize(width: ref.width, height: ref.height))
  #endif
 }
}
