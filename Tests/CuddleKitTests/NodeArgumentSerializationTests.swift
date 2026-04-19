//
//  NodeSerializationTests.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

import Testing
@testable import CuddleKit

struct NodeArgumentSerializationTests {
    @Test func nodeArgumentDeserializations() async throws {
        let node = KDLNode(named: "node", "foo", 11, 0.99, false, "chrysalis")
        let deserializer = KDLNodeArgumentSerializationContainer(node: node, path: KDLSerializationPath())

        let arg0 = try deserializer.deserialize(String.self)
        #expect(arg0 == "foo")

        let arg1 = try deserializer.deserialize(Int64.self)
        #expect(arg1 == 11)

        let arg2 = try deserializer.deserialize(Double.self)
        #expect(arg2 == 0.99)

        let arg3 = try deserializer.deserialize(Bool.self)
        #expect(arg3 == false)

        let arg4 = try deserializer.deserialize(Bughorse.self)
        #expect(arg4 == .chrysalis)

        #expect(throws: KDLDeserializationError.argumentIndexOutOfBounds(5, KDLSerializationPath())) {
            try deserializer.deserialize(String.self)
        }
    }

    @Test func nodeArgumentSerializations() async throws {
        let node = KDLNode(named: "node")
        let serializer = KDLNodeArgumentSerializationContainer(node: node, path: KDLSerializationPath())

        try serializer.serialize("foo")
        try serializer.serialize(Int64(11))
        try serializer.serialize(0.99)
        try serializer.serialize(true)
        try serializer.serialize(Bughorse.chrysalis)
        let finalNode = serializer.finalize()

        #expect(finalNode == KDLNode(named: "node", "foo", 11, 0.99, true, "chrysalis"))
    }
}
