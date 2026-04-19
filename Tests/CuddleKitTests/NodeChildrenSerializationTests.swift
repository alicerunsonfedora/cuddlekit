//
//  NodeChildrenSerializationTests.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 16-04-2026.
//

import Testing

@testable import CuddleKit

struct NodeChildrenSerializationTests {
    @Test func deserializeSingleChild() async throws {
        let node = KDLNode("manifest") {
            KDLNode(named: "version", 1)
        }

        let container = KDLNodeChildSerializationContainer(node: node, serializationPath: KDLSerializationPath())
        let child = try container.deserialize(SampleManifest.Version.self, forChildNamed: "version")
        #expect(child == SampleManifest.Version(version: 1))
    }

    @Test func deserializeChildrenArray() async throws {
        let node = KDLNode("players") {
            KDLNode(named: "player", properties: ["horse": "thorax", "initialStat": 5])
            KDLNode(named: "player", properties: ["horse": "chrysalis", "initialStat": 15])
            KDLNode(named: "player", properties: ["horse": "ocellus", "initialStat": 3])
        }

        let container = KDLNodeChildSerializationContainer(node: node, serializationPath: KDLSerializationPath())
        let players = try container.deserialize(SamplePropertyNode.self, forChildrenNamed: "player")

        #expect(
            players == [
                SamplePropertyNode(horse: .thorax, initialStat: 5),
                SamplePropertyNode(horse: .chrysalis, initialStat: 15),
                SamplePropertyNode(horse: .ocellus, initialStat: 3),
            ]
        )
    }

    @Test func deserializeChildrenSequential() async throws {
        let node = KDLNode("contacts") {
            KDLNode(named: "alice", arguments: [35], properties: ["displayName": "Alice Weiss"])
            KDLNode(named: "bob", arguments: [27])
            KDLNode(named: "charlie", arguments: [41], properties: ["displayName": "Charles Takanaka"])
        }

        let container = KDLNodeChildSerializationContainer(node: node, serializationPath: KDLSerializationPath())
        var people = [PersonSample]()
        while container.canSerializeOrDeserializeNextChild {
            people.append(try container.deserializeNextChild(PersonSample.self))
        }

        #expect(
            people == [
                PersonSample(name: "alice", displayName: "Alice Weiss", age: 35),
                PersonSample(name: "bob", age: 27),
                PersonSample(name: "charlie", displayName: "Charles Takanaka", age: 41),
            ]
        )
    }

    @Test func serialize() async throws {
        let expected = KDLNode("contacts") {
            KDLNode(named: "alice", arguments: [35], properties: ["displayName": "Alice Weiss"])
            KDLNode(named: "bob", arguments: [27])
            KDLNode(named: "charlie", arguments: [41], properties: ["displayName": "Charles Takanaka"])
        }

        let sample = ContactsSample(contacts: [
            PersonSample(name: "alice", displayName: "Alice Weiss", age: 35),
            PersonSample(name: "bob", age: 27),
            PersonSample(name: "charlie", displayName: "Charles Takanaka", age: 41),
        ])

        let container = KDLNodeChildSerializationContainer(
            node: KDLNode(named: "contacts"),
            serializationPath: KDLSerializationPath())

        for contact in sample.contacts {
            try container.serialize(contact)
        }

        let output = container.finalize()
        #expect(output == expected)
    }
}
