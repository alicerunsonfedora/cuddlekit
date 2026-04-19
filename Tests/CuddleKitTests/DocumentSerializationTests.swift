//
//  DocumentSerializationTests.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

import Testing

@testable import CuddleKit

struct DocumentSerializationTests {
    @Test func deserializeDocumentArgumentsOnly() async throws {
        let document = KDLDocument(kdlVersion: 2) {
            KDLNode(named: "character", "chrysalis", 5)
        }

        let serializer = KDLSerializer()
        let node = try serializer.deserialize(document, as: SampleArgumentNode.self)
        #expect(node.horse == .chrysalis)
        #expect(node.initialStat == 5)
    }

    @Test func serializeDocumentArgumentsOnly() async throws {
        let sample = SampleArgumentNode(horse: .chrysalis, initialStat: 5)
        let serializer = KDLSerializer()
        let document = try serializer.serialize(sample)

        #expect(document == KDLDocument(kdlVersion: 2, nodes: [KDLNode(named: "character", "chrysalis", 5)]))
    }

    @Test func deserializeDocumentPropertiesOnly() async throws {
        let document = KDLDocument(kdlVersion: 2) {
            KDLNode(named: "character", properties: ["horse": "chrysalis", "initialStat": 5])
        }
        let serializer = KDLSerializer()
        let node = try serializer.deserialize(document, as: SamplePropertyNode.self)
        #expect(node.horse == .chrysalis)
        #expect(node.initialStat == 5)
        #expect(node.comment == nil)
    }

    @Test func serializeDocumentPropertiesOnly() async throws {
        let sample = SamplePropertyNode(horse: .chrysalis, initialStat: 5)
        let serializer = KDLSerializer()
        let document = try serializer.serialize(sample)

        #expect(
            document
                == KDLDocument(
                    kdlVersion: 2,
                    nodes: [KDLNode(named: "character", properties: ["horse": "chrysalis", "initialStat": 5])]
                )
        )
    }

    @Test func deserializeStructuredDocument() async throws {
        let manifest = KDLDocument(kdlVersion: 2) {
            KDLNode("manifest") {
                KDLNode(named: "version", arguments: [1])
                KDLNode("dependencies") {
                    KDLNode(named: "libriven", "https://pkg.archivist.guild", properties: ["version": "^5.21.3"])
                    KDLNode(
                        named: "cuddlekit",
                        "https://source.marquiskurt.net/marquiskurt/cuddlekit",
                        properties: ["branch": "main"]
                    )
                }
            }
        }
        let deserializer = KDLSerializer()
        let manifestStruct = try deserializer.deserialize(manifest, as: PackageManifest.self)

        #expect(
            manifestStruct
                == PackageManifest(
                    version: 1,
                    dependencies: [
                        .dependency(name: "libriven", url: "https://pkg.archivist.guild", from: "^5.21.3"),
                        .dependency(
                            name: "cuddlekit",
                            url: "https://source.marquiskurt.net/marquiskurt/cuddlekit",
                            branch: "main"
                        ),
                    ]
                )
        )
    }

    @Test func serializeStructuredDocument() async throws {
        let expected = KDLDocument(kdlVersion: 2) {
            KDLNode("manifest") {
                KDLNode(named: "version", arguments: [1])
                KDLNode("dependencies") {
                    KDLNode(named: "libriven", "https://pkg.archivist.guild", properties: ["version": "^5.21.3"])
                    KDLNode(
                        named: "cuddlekit",
                        "https://source.marquiskurt.net/marquiskurt/cuddlekit",
                        properties: ["branch": "main"]
                    )
                }
            }
        }

        let manifest = PackageManifest(
            version: 1,
            dependencies: [
                .dependency(name: "libriven", url: "https://pkg.archivist.guild", from: "^5.21.3"),
                .dependency(
                    name: "cuddlekit",
                    url: "https://source.marquiskurt.net/marquiskurt/cuddlekit",
                    branch: "main"
                ),
            ]
        )

        let serializer = KDLSerializer()
        let document = try serializer.serialize(manifest)
        #expect(document == expected)
    }

    @Test func deserializeFromString() async throws {
        let manifest =
            """
            manifest {
                version 1

                dependencies {
                    libriven "https://pkg.archivist.guild" version="^5.21.3"
                    cuddlekit "https://source.marquiskurt.net/marquiskurt/cuddlekit" branch="main"
                }
            }
            """
        let serializer = KDLSerializer()
        let manifestStruct = try serializer.deserialize(manifest, as: PackageManifest.self)
        #expect(
            manifestStruct
                == PackageManifest(
                    version: 1,
                    dependencies: [
                        .dependency(name: "libriven", url: "https://pkg.archivist.guild", from: "^5.21.3"),
                        .dependency(
                            name: "cuddlekit",
                            url: "https://source.marquiskurt.net/marquiskurt/cuddlekit",
                            branch: "main"
                        ),
                    ]
                )
        )
    }
}
