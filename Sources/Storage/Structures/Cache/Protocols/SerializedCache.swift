import Foundation

/// An object that conforms to `Identifiable` & `AutoCodable`.
@available(macOS 10.15, iOS 13.0, *)
public typealias Cacheable = Identifiable & AutoCodable

@available(macOS 10.15, iOS 13.0, *)
public protocol SerializedCache: BaseCache
where Value: Cacheable,
			Value.ID == String,
			Value.AutoDecoder.Input == Data,
			Value.AutoEncoder.Output == Data {
	static subscript(_: Value.ID) -> Value? { get set }
}

@available(macOS 10.15, iOS 13.0, *)
public extension SerializedCache {
	/// An automatically determined location for `Value`
	/// to be stored based on `UUID`.
	static func fileURL(_ id: Value.ID) throws -> URL {
		try folder().appendingPathComponent(id)
	}

	func exists(_ id: Value.ID) throws -> Bool {
		try Self.fileExists(Self.fileURL(id))
	}

	static func dataContents() throws -> [Data] {
		try contents().map { try getData($0) }
	}

	static func getData(_ url: URL) throws -> Data {
		try Data(contentsOf: url, options: .uncachedRead)
	}

	static func objects() throws -> [Value] {
		try Value.decoder.decode(
			Value.self,
			fromArray: Self.dataContents()
		)
	}

	static func add(_ contents: [Value]) throws {
		let dir = try folder(createIfNeeded: true)
		try contents.forEach { value in
			let url =
				dir.appendingPathComponent(value.id)
			if !fileExists(url) {
				let data = try Value.encoder.encode(value)
				try data.write(to: url)
			}
		}
	}

	static func subtract(_ contents: [Value]) throws {
		var directory = try Self.contents()
		// remove values needed to cache
		contents.forEach { value in
			// check if already cached
			if let commonIndex =
				directory.firstIndex(
					where:
						{ $0.lastPathComponent == value.id }
				) {
				directory.remove(at: commonIndex)
			} else {
				// cache the new value if not
				Self[value.id] = value
			}
		}
		// delete the values needed to remove
		try directory.forEach { url in
			try fileManager.removeItem(at: url)
		}
	}
}

@available(macOS 10.15, iOS 13.0, *)
public extension SerializedCache where Value: SerializedImage {
	 static func trim() throws {
		guard let timeInterval = Value.expiration else { return }
		let expirationDate = Date() + timeInterval
		for object in try Self.objects()
		where object.timestamp.compare(expirationDate) == .orderedDescending {
			Self[object.id] = nil
		}
	}
}
