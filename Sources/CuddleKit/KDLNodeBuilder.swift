//
//  KDLNodeBuilder.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

/// A result builder used to create node trees more efficiently.
///
/// This result builder can be used to make node trees in a manner that more closely reflects a KDL document. For
/// example, the ``KDLNode`` accepts a builder closure for this purpose:
/// ```swift
/// let myNode = KDLNode("contacts") {
///     KDLNode(named: "contact", arguments: ["alice"], properties: ["age": 45])
///     KDLNode(named: "contact", arguments: ["bob"], properties: ["age": 27])
/// }
/// ```
@resultBuilder
public struct KDLNodeBuilder {
    public static func buildBlock(_ components: [KDLNode]...) -> [KDLNode] {
        components.flatMap { $0 }
    }

    public static func buildArray(_ components: [[KDLNode]]) -> [KDLNode] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: KDLNode) -> [KDLNode] {
        [expression]
    }

    public static func buildExpression(_ expression: [KDLNode]) -> [KDLNode] {
        expression
    }

    public static func buildEither(first component: [KDLNode]) -> [KDLNode] {
        component
    }

    public static func buildEither(second component: [KDLNode]) -> [KDLNode] {
        component
    }

    public static func buildOptional(_ component: [KDLNode]?) -> [KDLNode] {
        component ?? []
    }

    public static func buildLimitedAvailability(_ component: [KDLNode]) -> [KDLNode] {
        component
    }
}

extension KDLNode {
    /// Create a node by building its hierarchy.
    /// - Parameter name: The name of the node.
    /// - Parameter arguments: The node's ordered arguments.
    /// - Parameter properties: The node's properties.
    /// - Parameter builder: A closure that returns the node's children.
    public init(
        _ name: String,
        arguments: [KDLValue] = [],
        properties: KDLPropertyCollection = [:],
        @KDLNodeBuilder builder: () -> [KDLNode]
    ) {
        self.init(named: name, arguments: arguments, properties: properties, children: builder())
    }

    /// Create a node by building its hierarchy.
    /// - Parameter name: The name of the node.
    /// - Parameter arguments: The node's ordered arguments.
    /// - Parameter properties: The node's properties.
    /// - Parameter builder: A closure that returns the node's children.
    public init(
        _ name: String,
        _ arguments: KDLValue...,
        properties: KDLPropertyCollection = [:],
        @KDLNodeBuilder builder: () -> [KDLNode]
    ) {
        self.init(named: name, arguments: arguments, properties: properties, children: builder())
    }
}

extension KDLDocument {
    /// Create a KDL document by building its node hierarchy.
    /// - Parameter version: The version of the KDL specification this document represents.
    /// - Parameter builder: A closure that returns the document's node hierarchy.
    public init(kdlVersion version: Int, @KDLNodeBuilder builder: () -> [KDLNode]) {
        self.init(kdlVersion: version, nodes: builder())
    }
}
