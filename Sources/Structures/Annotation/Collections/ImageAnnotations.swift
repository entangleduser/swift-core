import Core

 /// A CreateML compatible annotation.
public struct CoordinateAnnotation<ID: Hashable & Codable & Infallible, Label: AnnotationLabel & Infallible>
: Infallible, SerialAnnotation, Codable, Hashable {
 public init(
  id: ID,
  annotations: Set<Self.Annotation>?
 ) {
  self.id = id
  self.annotations = annotations
 }
 public var id: ID
 // Data containing the coordinates and label of an annotation.
 public var annotations: Set<CoordinatesLabel<Label>>?
}
