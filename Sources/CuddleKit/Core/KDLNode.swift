//
//  KDLNode.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 11-04-2026.
//

/// A type representing and individual node in KDL.
public struct KDLNode: Equatable, Sendable {
    /// The node's name.
    public var name: String

    /// The arguments provided by the node.
    public var arguments: [KDLValue]

    /// The node's properties.
    public var properties: KDLPropertyCollection

    /// The node's children.
    public var children: [KDLNode]

    /// Create a node by building its hierarchy.
    /// - Parameter name: The name of the node.
    /// - Parameter arguments: The node's ordered arguments.
    /// - Parameter properties: The node's properties.
    /// - Parameter children: The node's children.
    public init(
        named name: String,
        arguments: [KDLValue] = [],
        properties: KDLPropertyCollection = [:],
        children: [KDLNode] = []
    ) {
        self.name = name
        self.arguments = arguments
        self.properties = properties
        self.children = children
    }

    /// Create a node by building its hierarchy.
    /// - Parameter name: The name of the node.
    /// - Parameter arguments: The node's ordered arguments.
    /// - Parameter properties: The node's properties.
    /// - Parameter children: The node's children.
    public init(
        named name: String,
        _ arguments: KDLValue...,
        properties: KDLPropertyCollection = [:],
        children: [KDLNode] = []
    ) {
        self.name = name
        self.arguments = arguments.map { $0 }
        self.properties = properties
        self.children = children
    }

    /// Access an argument at the specified index.
    public subscript(argument index: Int) -> KDLValue {
        get { return self.arguments[index] }
        set { self.arguments[index] = newValue }
    }

    /// Access a property with the given name.
    public subscript(property: String) -> KDLValue? {
        get { return self.properties[property] }
        set { self.properties[property] = newValue }
    }

    /// Access the first child with the given name.
    public subscript(child name: String) -> KDLNode? {
        get { return self.children.first(where: {$0.name == name }) }
    }

    /// Access a child node at the given index.
    public subscript(child index: Int) -> KDLNode {
        get { return self.children[index] }
        set { self.children[index] = newValue }
    }

    /// Traverse the node tree at the current position through the specified path.
    ///
    /// This method is typically used for fast navigation. For example, the following call looks for a node called
    /// `parameters` at the end of the tree, going through `scripts` and `run` first.
    ///
    /// ```swift
    /// let myChild = node.traverse(through: ["scripts", "run", "parameters"])
    /// ```
    ///
    /// If a node with any of the names in the path cannot be found, this method returns nil.
    /// - Parameter path: The path from the current position to the expected child node.
    public func traverse(through path: [String]) -> KDLNode? {
        guard !path.isEmpty else { return nil }
        var child = self
        for index in path.indices {
            guard let newChild = child[child: path[index]] else {
                return nil
            }
            child = newChild
        }
        return child
    }
}

/// A type representing a KDL document.
public struct KDLDocument: Equatable {
    /// The version of the KDL specification used.
    public var kdlVersion: Int

    /// The nodes contained within this document.
    public var nodes: [KDLNode]
}
