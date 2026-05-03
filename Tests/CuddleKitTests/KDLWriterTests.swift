//
//  KDLWriterTests.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 02-05-2026.
//

import Testing

@testable import CuddleKit

struct KDLWriterTests {
    @KDLNodeBuilder
    private var nodeTree: [KDLNode] {
        KDLNode("manifest") {
            KDLNode(named: "version", 1)
            KDLNode("dependencies") {
                KDLNode(
                    named: "cuddlekit",
                    arguments: ["https://source.marquiskurt.net/marquiskurt/CuddleKit"],
                    properties: ["branch": "main"]
                )
                KDLNode(
                    named: "libriven",
                    arguments: ["https://pkg.archivists.guild/riven"],
                    properties: ["version": "^5.21.3"]
                )
            }
        }
    }

    @Test func writeDocument() async throws {
        let writer = KDLWriter()
        let result = writer.write(KDLDocument(kdlVersion: 2, nodes: nodeTree))
        #expect(
            result ==
                """
                manifest {
                    version 1
                    dependencies {
                        cuddlekit "https://source.marquiskurt.net/marquiskurt/CuddleKit" branch=main
                        libriven "https://pkg.archivists.guild/riven" version=^5.21.3
                    }
                }
                
                """
        )
    }

    @Test func writeDocumentWithTypedValue() async throws {
        let tree = KDLDocument(kdlVersion: 2) {
            KDLNode(named: "foo", .typed(KDLTypedValue(annotation: "u8", value: 10)))
        }
        let writer = KDLWriter()
        let result = writer.write(tree)
        #expect(result == "foo (u8)10")
    }
}
