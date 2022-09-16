import Foundation

public protocol BaseCache: BaseStorage {
 static var key: String { get }
 init()
}

public extension BaseCache {
 static var fileManager: FileManager { FileManager.default }
 static func cache() throws -> URL {
  try FileManager.default.url(
   for: .cachesDirectory,
   in: .userDomainMask,
   appropriateFor: nil,
   create: false
  )
 }

 static func fileExists(_ url: URL) -> Bool {
  fileManager.fileExists(atPath: url.path)
 }

 @discardableResult
 static func folder(createIfNeeded: Bool = false) throws -> URL {
  let url = try cache().appendingPathComponent(key)
  if createIfNeeded {
   guard !fileManager.fileExists(atPath: url.path) else { return url }
   try fileManager.createDirectory(
    atPath: url.path,
    withIntermediateDirectories: true,
    attributes: nil
   )
  }
  return url
 }
 func contents() -> [URL] {
  do { return try Self.contents(createIfNeeded: false) }
  catch { debugPrint(error.localizedDescription) }
  return .empty
 }
 static func contents(
  createIfNeeded _: Bool = true
 ) throws -> [URL] {
  try fileManager
   .contentsOfDirectory(
    at: folder(createIfNeeded: true),
    includingPropertiesForKeys: nil,
    options: [
     .skipsHiddenFiles,
     .skipsSubdirectoryDescendants,
     .skipsPackageDescendants
    ]
   )
 }
 
 static func remove(_ paths: [String]) throws {
  for path in paths {
   try fileManager.removeItem(at: try folder().appendingPathComponent(path))
  }
 }

 static func clear() throws {
  try fileManager.removeItem(at: folder())
 }

 static var shared: Self { Self() }
}
