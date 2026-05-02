//
//  KDLWriter.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 02-05-2026.
//

import CKDL

/// A type that writes KDL document trees into string values.
public class KDLWriter {
    /// An enumeration for the different output formats for KDL identifiers.
    public enum IdentifierOutputFormat {
        /// Use bare identifiers unless it is absolutely necessary to wrap it in quotes.
        case bare

        /// Use bare identifiers only when it is represented by ASCII characters.
        case ascii

        /// Always wrap identifiers in quotes.
        case quotes

        var ckdlOption: kdl_identifier_emission_mode {
            switch self {
            case .bare: KDL_PREFER_BARE_IDENTIFIERS
            case .ascii: KDL_ASCII_IDENTIFIERS
            case .quotes: KDL_QUOTE_ALL_IDENTIFIERS
            }
        }
    }

    /// The number of spaces to use for indentation.
    public var indentSpacing: Int32 = 4

    /// The output format for identifiers (i.e., node names, arguments, etc.).
    public var identifierFormat: IdentifierOutputFormat = .bare

    var writer: OpaquePointer?
    
    public init() {
        // TODO: Implement
    }

    /// Write the specified KDL document as a string value.
    /// - Parameter document: The document to write as a string.
    public func write(_ document: KDLDocument) -> String {
        let options = kdl_emitter_options(
            indent: indentSpacing,
            escape_mode: KDL_ESCAPE_DEFAULT,
            identifier_mode: identifierFormat.ckdlOption,
            float_mode: kdl_float_printing_options(),
            version: Self.kdlVersion(document.kdlVersion)
        )

        return withUnsafePointer(to: options) { optionsPtr in
            self.writer = kdl_create_buffering_emitter(optionsPtr)
            for node in document.nodes {
                writeNode(node)
            }
            let buffer = kdl_get_emitter_buffer(writer)
            kdl_emit_end(writer)
            return String(kdlString: buffer)
        }
    }

    deinit {
        kdl_destroy_emitter(self.writer)
    }

    func writeNode(_ node: KDLNode) {
        node.name.withCString { ptr in
            let kdlString = kdl_str_from_cstr(ptr)
            kdl_emit_node(writer, kdlString)
        }
        for argument in node.arguments {
            var value = kdl_value(argument)
            kdl_emit_arg(writer, &value)
        }

        for (key, value) in node.properties {
            var kdlValue = kdl_value(value)
            let keyString = String(key)
            keyString.withCString { ptr in
                let name = kdl_str_from_cstr(ptr)
                kdl_emit_property(writer, name, &kdlValue)
            }
        }

        if node.children.isEmpty { return }
        kdl_start_emitting_children(writer)
        for child in node.children {
            writeNode(child)
        }
        kdl_emit_end(writer)
    }

    static func kdlVersion(_ version: Int) -> kdl_version {
        switch version {
        case 1: KDL_VERSION_1
        case 2: KDL_VERSION_2
        default: KDL_VERSION_1
        }
    }
}
