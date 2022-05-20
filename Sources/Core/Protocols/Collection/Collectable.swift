public protocol Collectable: Sequential & Collection {
 override associatedtype Base: Collection
 override associatedtype Element = Base.Element
 override associatedtype Iterator = Base.Iterator
 override associatedtype Index = Base.Index
 override associatedtype Indices = Base.Indices
 override associatedtype SubSequence = Base.SubSequence
}

public extension Collectable {
 @_transparent @inline(__always)
 var startIndex: Base.Index { _elements.startIndex }

 @_transparent @inline(__always)
 var endIndex: Base.Index { _elements.endIndex }

 @_transparent @inline(__always)
 var indices: Base.Indices { _elements.indices }

 @_transparent @inline(__always)
 func index(after i: Base.Index) -> Base.Index {
  _elements.index(after: i)
 }

 @inline(__always)
 subscript(position: Base.Index) -> Base.Element { _elements[position] }

 @inline(__always)
 subscript(bounds: Range<Base.Index>) -> Base.SubSequence { _elements[bounds] }

 @_transparent @inline(__always)
 func index(_ i: Base.Index, offsetBy distance: Int) -> Base.Index {
  _elements.index(i, offsetBy: distance)
 }

 @_transparent @inline(__always)
 func index(
  _ i: Base.Index,
  offsetBy distance: Int,
  limitedBy limit: Base.Index
 ) -> Base.Index? {
  _elements.index(i, offsetBy: distance, limitedBy: limit)
 }

 @_transparent @inline(__always)
 func distance(from start: Base.Index, to end: Base.Index) -> Int {
  _elements.distance(from: start, to: end)
 }

 @_transparent @inline(__always)
 func formIndex(after i: inout Base.Index) {
  _elements.formIndex(after: &i)
 }

 @_transparent @inline(__always)
 var count: Int {
  _elements.count
 }

 @_transparent @inline(__always)
 var isEmpty: Bool {
  _elements.isEmpty
 }
}
