//
//  KDLNode.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 11-04-2026.
//

public struct KDLNode: Equatable, Sendable {
    #if Embedded && hasFeature(Embedded)
        public typealias PropertyKey = String.UTF8View
    #else
        public typealias PropertyKey = String
    #endif
    public var name: String
    public var arguments: [KDLValue]
    public var properties: [PropertyKey: KDLValue]
    public var children: [KDLNode]

    public init(
        named name: String,
        arguments: [KDLValue] = [],
        properties: [PropertyKey: KDLValue] = [:],
        children: [KDLNode] = []
    ) {
        self.name = name
        self.arguments = arguments
        self.properties = properties
        self.children = children
    }

    public init(
        named name: String,
        _ arguments: KDLValue...,
        properties: [PropertyKey: KDLValue] = [:],
        children: [KDLNode] = []
    ) {
        self.name = name
        self.arguments = arguments.map { $0 }
        self.properties = properties
        self.children = children
    }
}

public struct KDLDocument: Equatable {
    public var kdlVersion: Int
    public var nodes: [KDLNode]
}
