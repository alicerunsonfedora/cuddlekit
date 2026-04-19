//
//  SerializationPath.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

/// A structure that represents a serialization path.
///
/// As a ``KDLSerializer`` traverses through a KDL document tree, this type is used to keep track of its current
/// traversal. Paths can either represent raw indices or keyed names.
public struct KDLSerializationPath: Equatable, Sendable {
    /// An enumeration of path types a serialization path can contain.
    public enum Node: Equatable, Sendable {
        /// An ordered index.
        case index(Int)

        /// A named node path.
        case key(String)
    }

    var nodes: [Node]

    /// Create a serialization path.
    public init() {
        self.nodes = []
    }

    init(_ nodes: [Node]) {
        self.nodes = nodes
    }

    /// Creates a serialization path, appending the key to the end of the path.
    /// - Parameter key: The key to append to the serialization path.
    public func appending(_ key: String) -> Self {
        var newSelf = self
        newSelf.push(key)
        return newSelf
    }

    /// Creates a serialization path, appending an index to the end of the path.
    /// - Parameter index: The index to append to the serialization path.
    public func appending(_ index: Int) -> Self {
        var newSelf = self
        newSelf.push(index)
        return self
    }

    /// Adds the specified key to the end of the serialization path.
    /// - Parameter key: The key to append to the end of the path.
    public mutating func push(_ key: String) {
        nodes.append(.key(key))
    }

    /// Adds the specified index to the end of the serialization path.
    /// - Parameter index: The index to append to the end of the path.
    public mutating func push(_ index: Int) {
        nodes.append(.index(index))
    }

    /// Removes the current ending path from the serialization path.
    @discardableResult
    public mutating func pop() -> Node? {
        if nodes.isEmpty { return nil }
        return nodes.removeLast()
    }
}

extension KDLSerializationPath: Collection {
    public typealias Element = Node

    public var startIndex: [Node].Index {
        nodes.startIndex
    }

    public var endIndex: [Node].Index {
        nodes.endIndex
    }

    public func index(after i: Int) -> Int {
        nodes.index(after: i)
    }

    public subscript(position: Int) -> Node {
        nodes[position]
    }
}
