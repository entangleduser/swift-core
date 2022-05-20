import Core

public typealias ExpressibleAsLabel = RawRepresentable & Codable & Hashable
// Potential UI Considerations
//  & Identifiable & CaseIterable & OptionSet
/// A label for coding of annotation labels.
public protocol AnnotationLabel: ExpressibleAsLabel {
 //init(rawValue: RawValue)
}

public extension AnnotationLabel where Self: Identifiable {
 var id: RawValue { rawValue }
}

/// The protocol to which all annotations must conform to.
public protocol Annotation: Codable, Hashable {
 associatedtype Label: AnnotationLabel
 var label: Label { get set }
 init()
}

public extension Annotation where Label: Infallible {
 static var defaultValue: Self { Self() }
}

/// An annotation that supports (optional) nested annotations.
public protocol Annotatable: Codable, Hashable {
 associatedtype Annotation: Structures.Annotation
 typealias Label = Annotation.Label
 var annotations: Set<Annotation>? { get set }
}

/// A protocol for that all serialized annotations conform to.
public protocol SerialAnnotation: Annotatable, Identifiable
where ID: Codable {
 init(id: ID, annotations: Set<Annotation>?)
}

public extension SerialAnnotation {
 init(
  _ id: ID,
  annotations: Set<Self.Annotation>? = .none
 ) {
  self.init(id: id, annotations: annotations)
 }

 func converted<A: SerialAnnotation>(to _: A.Type) -> A
 where A.Annotation == Self.Annotation, A.ID == Self.ID {
  A(id: id, annotations: annotations)
 }
}

//extension SerialAnnotation where Annotation == CoordinatesLabel<Label> {
// func converted<A: SerialAnnotation>(to _: A.Type) -> A
// where
// Self.Annotation == A.Annotation,
// A.Annotation == Self.Annotation,
// A.ID == Self.ID {
//  A(
//   id: id,
//   annotations:
//    annotations.map {
//     CoordinatesLabel(
//      label: A.Label(rawValue: $0.label.rawValue),
//      coordinates: $0.coordinates
//     )
//    }
//  )
// }
//}

public extension SerialAnnotation where Self.ID: Infallible {
 static var defaultValue: Self { Self() }
 init(
  _ id: ID = .defaultValue,
  annotations: Set<Self.Annotation>? = .none
 ) {
  self.init(id: id, annotations: annotations)
 }

 init() {
  self.init(id: .defaultValue, annotations: .none)
 }
}
