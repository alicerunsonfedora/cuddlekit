// The Swift Programming Language
// https://docs.swift.org/swift-book

import CKDL

/// A type that creates KDL document trees by reading values.
public class KDLReader {
    /// An enumeration representing the errors that can be thrown when reading a value.
    public enum ReaderError: Error {
        /// An error occurred when parsing the document.
        case parseError

        /// The reader entered an invalid starting node state.
        case invalidNodeStart

        /// The reader encountered an invalid document version.
        ///
        /// This error can also be thrown when the reader has no options regarding which versions should be considered
        /// for parsing.
        case invalidDocumentVersion
    }

    /// An enumeration representing the options that can be provided to a reader.
    public enum ReaderOption: Equatable, Sendable {
        /// Parse documents that follow the KDLv1 specification.
        case parse_v1

        /// Parse documents that follow the KDLv2 specification.
        case parse_v2
    }

    /// The options used to configure this reader.
    public var options: Set<ReaderOption>

    public init() {
        self.options = [.parse_v1, .parse_v2]
    }

    /// Read a string value as a KDL document and generate a node tree.
    /// - Parameter string: The string value to read.
    public func read(_ string: String) throws(ReaderError) -> KDLDocument {
        if !options.contains(.parse_v2), !options.contains(.parse_v1) {
            throw .invalidDocumentVersion
        }
        do {
            try guaranteeParseV2()
            let parser_V2 = KDLParser(source: string, options: KDL_READ_VERSION_2)
            return try parse(parser_V2, version: 2)
        } catch {
            try guaranteeParseV1()
            let parser_V1 = KDLParser(source: string, options: KDL_READ_VERSION_1)
            do {
                return try parse(parser_V1, version: 1)
            } catch {
                throw .parseError
            }
        }
    }

    func guaranteeParseV2() throws(ReaderError) {
        guard options.contains(.parse_v2) else {
            throw .invalidDocumentVersion
        }
    }

    func guaranteeParseV1() throws(ReaderError) {
        guard options.contains(.parse_v1) else {
            throw .invalidDocumentVersion
        }
    }

    #if Embedded && hasFeature(Embedded)
        func parse(_ parser: KDLParser, version: Int) throws(ReaderError) -> KDLDocument {
            var event = try parser.advance()
            var nodes = [KDLNode]()
            while event != nil {
                switch event {
                case .startNode:
                    let node = try readNode(parser)
                    nodes.append(node)
                case .comment:
                    continue
                default:
                    break
                }
                event = try parser.advance()
            }
            return KDLDocument(kdlVersion: version, nodes: nodes)
        }
    #else
        func parse(_ parser: KDLParser, version: Int) throws -> KDLDocument {
            var event = try parser.advance()
            var nodes = [KDLNode]()
            while event != nil {
                switch event {
                case .startNode:
                    let node = try readNode(parser)
                    nodes.append(node)
                case .comment:
                    continue
                default:
                    break
                }
                event = try parser.advance()
            }
            return KDLDocument(kdlVersion: version, nodes: nodes)
        }
    #endif

    func readNode(_ parser: KDLParser) throws(ReaderError) -> KDLNode {
        guard case .startNode(let nodeName) = parser.currentEvent else {
            throw .invalidNodeStart
        }
        var nodeArguments = [KDLValue]()
        var nodeProperties = KDLPropertyCollection()
        var childrenNodes = [KDLNode]()

        #if Embedded && hasFeature(Embedded)
            var event = try parser.advance()
            while event != nil && event != .endNode {
                switch event {
                case .startNode:
                    let child = try readNode(parser)
                    childrenNodes.append(child)
                case .argument(let value):
                    if let value {
                        nodeArguments.append(value)
                    }
                case .property(let key, let value):
                    if let value {
                        nodeProperties[key.utf8] = value
                    }
                case .comment:
                    continue
                default:
                    break
                }
                event = try parser.advance()
            }
            return KDLNode(
                named: nodeName,
                arguments: nodeArguments,
                properties: nodeProperties,
                children: childrenNodes
            )
        #else
            do {
                var event = try parser.advance()
                while event != nil && event != .endNode {
                    switch event {
                    case .startNode:
                        let child = try readNode(parser)
                        childrenNodes.append(child)
                    case .argument(let value):
                        if let value {
                            nodeArguments.append(value)
                        }
                    case .property(let key, let value):
                        if let value {
                            nodeProperties[key] = value
                        }
                    case .comment:
                        continue
                    default:
                        break
                    }
                    event = try parser.advance()
                }
                return KDLNode(
                    named: nodeName,
                    arguments: nodeArguments,
                    properties: nodeProperties,
                    children: childrenNodes
                )
            } catch {
                throw .parseError
            }
        #endif
    }
}
