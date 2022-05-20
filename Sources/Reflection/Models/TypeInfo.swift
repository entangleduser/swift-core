public struct TypeInfo {
 public let kind: Kind
 public let name: String
 public let type: Any.Type
 public let mangledName: String
 public let properties: [PropertyInfo]
 public let size: Int
 public let alignment: Int
 public let stride: Int
 public let genericTypes: [Any.Type]

 init(metadata: StructMetadata) {
  kind = metadata.kind
  name = String(describing: metadata.type)
  type = metadata.type
  size = metadata.size
  alignment = metadata.alignment
  stride = metadata.stride
  properties = metadata.properties()
  mangledName = metadata.mangledName()
  genericTypes = Array(metadata.genericArguments())
 }

 public func property(named: String) -> PropertyInfo? {
  properties.first(where: { $0.name == named })
 }
}

public func typeInfo(of type: Any.Type) -> TypeInfo? {
 guard Kind(type: type) == .struct else {
  return nil
 }

 return StructMetadata(type: type).toTypeInfo()
}
