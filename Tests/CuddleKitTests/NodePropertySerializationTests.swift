//
//  NodePropertySerializationTests.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

import Testing
@testable import CuddleKit

struct NodePropertySerializationTests {
    @Test func deserializeProperties() async throws {
        let node = KDLNode(named: "foo", properties: ["horse": "thorax", "initialStat": 5])

        let container = KDLNodePropertySerializationContainer(node: node, serializationPath: KDLSerializationPath([.key("foo")]))

        let initialStat = try container.deserialize(Int64.self, forKey: "initialStat")
        #expect(initialStat == 5)

        let horse = try container.deserialize(Bughorse.self, forKey: "horse")
        #expect(horse == .thorax)

        let comment = try container.deserializeIfPresent(String.self, forKey: "comment")
        #expect(comment == nil)

        #expect(throws: KDLDeserializationError.valueNotFound(KDLSerializationPath([.key("foo"), .key("bar")]))) {
            try container.deserialize(Bool.self, forKey: "bar")
        }
    }

    @Test func serializeProperties() async throws {
        let container = KDLNodePropertySerializationContainer(
            node: KDLNode(named: "node"),
            serializationPath: KDLSerializationPath()
        )
        try container.serialize(Bughorse.thorax, forKey: "horse")
        try container.serialize(Int64(5), forKey: "initialStat")

        let finalNode = container.finalize()
        #expect(finalNode == KDLNode(named: "node", properties: ["horse": "thorax", "initialStat": 5]))
    }
}
