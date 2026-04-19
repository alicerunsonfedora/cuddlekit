//
//  KDLReaderTests.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 11-04-2026.
//

import Testing

@testable import CuddleKit

struct KDLReaderTests {
    let myDocument =
        """
        manifest {
            version 1

            dependencies {
                cuddlekit "https://source.marquiskurt.net/marquiskurt/CuddleKit" branch="main"
                libriven "https://pkg.archivists.guild/riven" version="^5.21.3"
            }
        }
        """

    @Test("Automatic read")
    func readerProducesAutomaticDocument() async throws {
        let reader = KDLReader()
        let document = try reader.read(myDocument)

        #expect(document == KDLDocument(kdlVersion: 2, nodes: expectedNodeTree))
    }

    @Test("Read v2 documents")
    func readerProducesV2DocumentOnly() async throws {
        let reader = KDLReader()
        reader.options = [.parse_v2]
        let document = try reader.read(myDocument)

        #expect(document == KDLDocument(kdlVersion: 2, nodes: expectedNodeTree))
    }

    @Test("Read v1 documents")
    func readerProducesV1DocumentOnly() async throws {
        let reader = KDLReader()
        reader.options = [.parse_v1]
        let document = try reader.read(myDocument)

        #expect(document == KDLDocument(kdlVersion: 1, nodes: expectedNodeTree))
    }

    @Test("Error handling")
    func readerError() async throws {
        let invalidKDL =
            """
            manifest {
                version 2

                test "me" "now"
                    orelse
                }
            }
            """
        let reader = KDLReader()
        #expect(throws: KDLReader.ReaderError.parseError) {
            try reader.read(invalidKDL)
        }
    }

    @KDLNodeBuilder
    private var expectedNodeTree: [KDLNode] {
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
}
