//
//  KDLNodeBuilder.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

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
    public init(
        _ name: String,
        arguments: [KDLValue] = [],
        properties: KDLPropertyCollection = [:],
        @KDLNodeBuilder builder: () -> [KDLNode]
    ) {
        self.init(named: name, arguments: arguments, properties: properties, children: builder())
    }

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
    public init(kdlVersion version: Int, @KDLNodeBuilder builder: () -> [KDLNode]) {
        self.init(kdlVersion: version, nodes: builder())
    }
}
