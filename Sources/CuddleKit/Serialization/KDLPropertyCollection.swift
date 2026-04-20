//
//  KDLPropertyCollection.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 20-04-2026.
//

/// A wrapper collection type used to manage KDL node properties.
///
/// This wrapper type is used to access KDL node properties in a way that preserves compatibility between standard and
/// embedded Swift contexts. Internally, values are stored by their UTF-8 view as keys, rather than the raw string
/// itself.
public struct KDLPropertyCollection: Equatable, Sendable {
    var properties: [String.UTF8View: KDLValue]

    /// Create an empty property collection.
    public init() {
        self.properties = [:]
    }

    public subscript(key: String) -> KDLValue? {
        get { return properties[key.utf8] }
        set { self.properties[key.utf8] = newValue }
    }

    public subscript(key: String.UTF8View) -> KDLValue? {
        get { return properties[key] }
        set { self.properties[key] = newValue }
    }

    public subscript(position: Index) -> (String.UTF8View, KDLValue) {
        self.properties[position]
    }
}

extension KDLPropertyCollection: Collection {
    public typealias Element = (String.UTF8View, KDLValue)
    public typealias Index = Dictionary<String.UTF8View, KDLValue>.Index

    public var startIndex: Index { self.properties.startIndex }
    public var endIndex: Index { self.properties.endIndex }

    public func index(after index: Index) -> Index {
        properties.index(after: index)
    }
}

extension KDLPropertyCollection: Sequence {}

extension KDLPropertyCollection: ExpressibleByDictionaryLiteral {
    public typealias Key = String
    public typealias Value = KDLValue

    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.properties = [:]
        for (key, value) in elements {
            self.properties[key.utf8] = value
        }
    }

    public init(dictionaryLiteral elements: (String.UTF8View, Value)...) {
        self.properties = [:]
        for (key, value) in elements {
            self.properties[key] = value
        }
    }
}
