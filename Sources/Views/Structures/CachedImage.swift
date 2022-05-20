import SwiftUI

@available(macOS 11.0, *)
public struct CachedImage: Identifiable, Equatable, Hashable, View {
 public static func == (lhs: CachedImage, rhs: CachedImage) -> Bool {
  lhs.id == rhs.id
 }
 
 public func hash(into hasher: inout Hasher) {
  hasher.combine(id)
 }
 @Environment(\.displayScale) var displayScale
 @Binding public var averageColor: Color?
 private var inMemory: Bool
 private let placeholder: KeyPath<Image.Placeholder, Image>?
 private var thumbnail: Bool
 private let thumbnailSize: Int
 private let placeholderInset: CGFloat
 public var id: String?

 public var cachedImage: ImageCache? {
  guard let id = id else {
   return nil
  }
  if thumbnail {
   if let thumbnailImage = ImageCache.memory.thumbnails[id]?[thumbnailSize] {
    return thumbnailImage
   } else {
    if let cachedImage = ImageCache.Storage[id],
       let thumbnail =
       cachedImage.image?.thumbnail(
        of: CGFloat(thumbnailSize) * displayScale
       ) {
     ImageCache.memory.thumbnails[id] = .empty
     ImageCache.memory.thumbnails[id]?[thumbnailSize] =
      ImageCache(thumbnail, cachedImage.timestamp)
     return ImageCache.memory.thumbnails[id]?[thumbnailSize]
    } else if ImageCache.memory.thumbnails[id] != nil {
     ImageCache.memory.thumbnails[id] = nil
    }
   }
  } else if inMemory {
   if ImageCache.memory.images[id] == nil {
    if let image = ImageCache.Storage[id] {
     ImageCache.memory.images[id] = image
    } else if ImageCache.memory.images[id] != nil {
     ImageCache.memory.images[id] = nil
    }
   }
   return ImageCache.memory.images[id]
  }
  return ImageCache.Storage[id]
 }

 public var nativeImage: NativeImage? {
  let image = cachedImage?.image
  if averageColor != .none, let color = image?.averageColor {
   averageColor = Color(color)
  }
  return image
 }
 public var image: Image? {
  Image(nativeImage: nativeImage).resizable()
 }

 public var body: some View {
  if let nativeImage = nativeImage,
     let image = image {
    image.aspectRatio(nativeImage.aspectRatio, contentMode: .fill)
  } else if let placeholder = placeholder {
   let image =
    Image.Placeholder.shared[keyPath: placeholder]
     .resizable()
     .aspectRatio(contentMode: .fill)
   Group {
    if thumbnail {
     image
      .padding(placeholderInset)
      .frame(maxHeight: CGFloat(thumbnailSize))
    } else {
     image
      .padding(placeholderInset)
    }
   }
  }
 }

 public init?(
  id: String,
  url: URL? = .none,
  path: String? = .none,
  placeholder: KeyPath<Image.Placeholder, Image>? = .none,
  placeholderImage: UIImage? = .none,
  thumbnail: Bool = false,
  size: Int = 64,
  placeholderInset: CGFloat = 0,
  inMemory: Bool = false,
  averageColor: Binding<Color?> = .constant(.none)
 ) {
  self.placeholder = placeholder
  self.thumbnail = thumbnail
  thumbnailSize = size
  self.placeholderInset = placeholderInset
  self.inMemory = inMemory
  _averageColor = averageColor
  guard
   let id = id.wrapped,
   let path = url?.absoluteString.wrapped ?? path?.wrapped
  else { return nil }
  self.id = id
  if ImageCache.Storage[id] == nil {
   if let url = url ?? URL(string: path),
      let data = try? Data(contentsOf: url) {
    try? data.write(to: ImageCache.Storage.fileURL(id))
   } else if let data =
    ImageCache(
     placeholderImage ?? UIImage() //Avatar(grid: (6, 6)).image(with: 1)
    ).data {
    try? data.write(to: ImageCache.Storage.fileURL(id))
    self.inMemory = true
    self.thumbnail = true
   }
  }
 }
}

public struct PreloadedImage<ModifiedImage: View>: View {
 public let modifiedImage: ModifiedImage
 public var body: some View { modifiedImage }

 public init?(
  id: String,
  url: URL? = .none,
  path: String? = .none,
  thumbnail: Bool = false,
  size: Int = 64,
  inMemory: Bool = true,
  @ViewBuilder cachedImage: @escaping (CachedImage) -> ModifiedImage
 ) {
  guard let image =
   CachedImage(
    id: id,
    url: url,
    path: path,
    placeholder: \.photo,
    thumbnail: thumbnail,
    size: size,
    inMemory: inMemory
   )
  else { return nil }
  modifiedImage = cachedImage(image)
 }
}

public extension PreloadedImage where ModifiedImage == EmptyView {
 @discardableResult
 @_disfavoredOverload
 init?(
  id: String,
  url: URL? = .none,
  path: String? = .none,
  thumbnail: Bool = false,
  size: Int = 64,
  inMemory: Bool = true,
  completion: ((UIImage?) -> ())?
 ) {
  self.init(
   id: id,
   url: url, path: path, thumbnail: thumbnail, size: size, inMemory: inMemory,
   cachedImage: {
    completion?($0.nativeImage)
    return EmptyView()
   }
  )
 }
}

public extension PreloadedImage where ModifiedImage == CachedImage {
 init?(
  id: String,
  url: URL? = .none,
  path: String? = .none,
  thumbnail: Bool = false, size: Int = 64, inMemory: Bool = true
 ) {
  self.init(
   id: id,
   url: url, path: path, thumbnail: thumbnail,
   size: size,
   inMemory: inMemory,
   cachedImage: { $0 }
  )
 }
}
