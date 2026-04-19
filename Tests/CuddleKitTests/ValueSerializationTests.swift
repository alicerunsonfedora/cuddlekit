//
//  ValueSerializationTests.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

import Testing
@testable import CuddleKit

struct ValueSerializationTests {
    @Test func stringValueDeserialization() async throws {
        let value: KDLValue = "foo"
        let container = KDLValueSerializationContainer(value: value, path: KDLSerializationPath())
        let decoded = try container.deserialize(String.self)
        #expect(decoded == "foo")
    }

    @Test func doubleValueDeserialization() async throws {
        let value: KDLValue = 0.99
        let container = KDLValueSerializationContainer(value: value, path: KDLSerializationPath())
        let decoded = try container.deserialize(Double.self)
        #expect(decoded == 0.99)
    }

    @Test func boolValueDeserialization() async throws {
        let value: KDLValue = false
        let container = KDLValueSerializationContainer(value: value, path: KDLSerializationPath())
        let decoded = try container.deserialize(Bool.self)
        #expect(decoded == false)
    }

    @Test func intValueDeserialization() async throws {
        let value: KDLValue = 100
        let container = KDLValueSerializationContainer(value: value, path: KDLSerializationPath())
        let decoded = try container.deserialize(Int64.self)
        #expect(decoded == 100)
    }

    @Test func customValueDeserialization() async throws {
        let value: KDLValue = "ocellus"
        let container = KDLValueSerializationContainer(value: value, path: KDLSerializationPath())
        let decoded = try container.deserialize(Bughorse.self)
        #expect(decoded == .ocellus)
    }

    @Test func deserializationMismatch() async throws {
        let value: KDLValue = "foo"
        let container = KDLValueSerializationContainer(value: value, path: KDLSerializationPath())
        #expect(throws: KDLDeserializationError.typeValueMismatch(KDLSerializationPath())) {
            try container.deserialize(Double.self)
        }
    }

    @Test func stringSerialization() async throws {
        let value = "foo"
        let container = KDLValueSerializationContainer(value: .untyped(.string("")), path: KDLSerializationPath())
        try container.serialize(value)
        let finalValue = container.finalize()
        #expect(finalValue == .untyped(.string("foo")))
    }

    @Test func boolSerialization() async throws {
        let value = true
        let container = KDLValueSerializationContainer(value: .untyped(.string("")), path: KDLSerializationPath())
        try container.serialize(value)
        let finalValue = container.finalize()
        #expect(finalValue == .untyped(.boolean(true)))
    }

    @Test func intSerialization() async throws {
        let value: Int64 = 100
        let container = KDLValueSerializationContainer(value: .untyped(.string("")), path: KDLSerializationPath())
        try container.serialize(value)
        let finalValue = container.finalize()
        #expect(finalValue == .untyped(.number(.integer(100))))
    }

    @Test func doubleSerialization() async throws {
        let value = 0.99
        let container = KDLValueSerializationContainer(value: .untyped(.string("")), path: KDLSerializationPath())
        try container.serialize(value)
        let finalValue = container.finalize()
        #expect(finalValue == .untyped(.number(.floating(0.99))))
    }

    @Test func customSerialization() async throws {
        let value = Bughorse.thorax
        let container = KDLValueSerializationContainer(value: .untyped(.string("")), path: KDLSerializationPath())
        try container.serialize(value)
        let finalValue = container.finalize()
        #expect(finalValue == .untyped(.string("thorax")))
    }

}
