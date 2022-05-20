import Core

public struct CoordinatesLabel<Label: AnnotationLabel & Infallible>
: Annotation, Codable, Hashable {
 public init() {}
 /// Required label for classifying an annotation.
 public var label: Label = .defaultValue
 /// Data containing coordinates relevant to the label.
 /// Should match the dimensions of the container if `nil` and match the center
 /// if `zero`.
 public var coordinates: Coordinates?
 public init(label: Label, coordinates: Coordinates? = .none) {
  self.label = label
  self.coordinates = coordinates
 }
}
