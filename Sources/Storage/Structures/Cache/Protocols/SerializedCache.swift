import Foundation
import Core

@available(macOS 10.15, iOS 13.0, *)
public protocol SerializedCache: BaseCache
where Value: AutoCodable {
 static subscript(_: AnyHashable) -> Value? { get set }
}

@available(macOS 10.15, iOS 13.0, *)
public extension SerializedCache {
 /// A file location for `Value` to be stored based on `ID`.
 static func fileURL(_ id: AnyHashable) throws -> URL {
  try folder().appendingPathComponent(id.description)
 }

 func exists(_ id: AnyHashable) throws -> Bool {
  try Self.fileExists(Self.fileURL(id))
 }

 static func dataContents() throws -> [(AnyHashable, Data)] {
  try contents().compactMap { ($0.lastPathComponent, try getData($0)) }
 }

 static func getData(_ url: URL) throws -> Data {
  try Data(contentsOf: url, options: .uncachedRead)
 }

 static func objects() throws -> [(AnyHashable, Value)] {
  try dataContents().compactMap {
   ($0.0.description, try Value.decoder.decode(Value.self, from: $0.1))
  }
 }

 static func add(_ contents: [(AnyHashable, Value)]) throws {
  let dir = try folder(createIfNeeded: true)
  try contents.forEach { value in
   let url =
   dir.appendingPathComponent(value.0.description)
   if !fileExists(url) {
    let data = try Value.encoder.encode(value.1)
    try data.write(to: url)
   }
  }
 }

 static func subtract(_ contents: [(AnyHashable, Value)]) throws {
  var directory =
  try Self.contents()
   .sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
  // remove values needed to cache
  contents.sorted(by: { $0.0.description < $1.0.description }).forEach { value in
   // check if already cached
   if let commonIndex =
    directory.firstIndex(
     where: { $0.lastPathComponent == value.0.description }
    ) {
    directory.remove(at: commonIndex)
   } else {
    debugPrint("Caching \(Value.self) (\(value.0))")
    // cache the new value if not
    Self[value.0] = value.1
   }
  }
  // delete the values needed to remove
  try directory.forEach { url in
   try fileManager.removeItem(at: url)
  }
 }

 @discardableResult
 func revealCount() -> Int {
  let count = contents().count
  debugPrint("\(count) \(Value.self)s Cached.")
  return count
 }
 
 func byteSize() -> Int {
  var bytes: Int = 0
  for url in contents() {
   guard let size = try? Self.fileManager
          .attributesOfItem(atPath: url.path)[.size] as? NSNumber
   else { continue }
   bytes += size.intValue
  }
  return bytes
 }
 
 func revealByteSize() {
  let size =
  Measurement<UnitInformationStorage>(value: Double(byteSize()), unit: .bytes)
  let byteCountFormatter: ByteCountFormatter = {
   let formatter = ByteCountFormatter()
   formatter.allowedUnits = [.useKB, .useMB, .useGB]
   return formatter
  }()
  debugPrint(
   "\(Self.self) has a size of \(byteCountFormatter.string(from: size))"
  )
 }
}

@available(macOS 10.15, iOS 13.0, *)
public extension SerializedCache where Value: CacheExpirable {
 func revealOldest() {
  let dates = contents()
   .compactMap {
    try? Self.fileManager.attributesOfItem(atPath: $0.path)[.creationDate] as? Date
   }
  if let interval = Value.expiration,
     let oldest = dates.sorted().first {
   let durationFormatter: MeasurementFormatter = {
    let formatter = MeasurementFormatter()
    formatter.unitStyle = .long
    formatter.unitOptions = .providedUnit
    return formatter
   }()

   let age =
    Measurement<UnitDuration>(
     value: Date.now.timeIntervalSince(oldest), unit: .seconds
    ).converted(to: .hours)

   let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.doesRelativeDateFormatting = true
    formatter.dateStyle = .full
    return formatter
   }()

   dateFormatter.dateStyle = .full

   let creation = dateFormatter.string(from: oldest)
   let expiration = dateFormatter.string(from: oldest + interval)
   let due =
    Measurement<UnitDuration>(
     value: (oldest + interval).timeIntervalSinceNow, unit: .seconds
    ).converted(to: .hours)

   debugPrint(
    """
    The oldest \(Value.self) is \(
     age.value > 24 ? "\((age.value / 24).rounded()) days" :
      durationFormatter.string(from: age)
    ) old, was created \(creation) and will be trimmed in \(
     due.value > 24 ? "\((due.value / 24).rounded()) days" :
      durationFormatter.string(from: due)) \(expiration).
    """
   )
  }
 }

 func trim() {
  do {
   let count = revealCount()
   revealByteSize()
   revealOldest()
   try Self.trim()
   debugPrint("\(count - contents().count) \(Value.self)s Trimmed.")
  } catch { debugPrint(error.localizedDescription) }
 }

 static func trim() throws {
  guard let interval = Value.expiration else { return }
  for url in try Self.contents() {
   guard let creation =
    try fileManager.attributesOfItem(
     atPath: url.path
    )[.creationDate] as? Date else {
    throw Cache<Value>.Error<Value>.read(
     description:
     "Couldn't find creation date for item with id: \(url.lastPathComponent)"
    )
   }
   let expiration = creation + interval
   if expiration.timeIntervalSinceNow < 0 {
    debugPrint(
     """
     Removing \(Self.self)<\(Value.self)>(\(url.lastPathComponent)) with creati\
     on date: \(creation), expiration: \(expiration), interval: \(interval)
     """
    )
    try fileManager.removeItem(at: url)
   }
  }
 }
}
