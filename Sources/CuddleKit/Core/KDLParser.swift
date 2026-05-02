//
//  KDLParser.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 11-04-2026.
//

import CKDL

class KDLParser {
    enum ParserError: Error {
        case internalParseError(String)
    }

    enum Event: Equatable {
        case startNode(String)
        case endNode
        case argument(KDLValue?)
        case property(String, KDLValue?)
        case comment
    }

    typealias Options = kdl_parse_option

    let source: String
    let options: kdl_parse_option

    var currentEvent: Event? {
        guard let event = event else { return nil }
        switch event.event {
        case KDL_EVENT_START_NODE:
            return .startNode(String(kdlString: event.name))
        case KDL_EVENT_ARGUMENT:
            return .argument(KDLValue(ckdlVal: event.value))
        case KDL_EVENT_PROPERTY:
            return .property(String(kdlString: event.name), KDLValue(ckdlVal: event.value))
        case KDL_EVENT_END_NODE:
            return .endNode
        case KDL_EVENT_COMMENT:
            return .comment
        default:
            return nil
        }
    }

    private var parser: OpaquePointer?
    private var event: kdl_event_data?

    init(source: String, options: Options = KDL_DEFAULTS) {
        self.source = source
        self.options = options

        #if Embedded && hasFeature(Embedded)
        source.withCString { cStr in
            let kdlString = kdl_str(data: cStr, len: source.utf8.count)
            self.parser = kdl_create_string_parser(kdlString, options)
        }
        #else
        source.withCString { cStr in
            let kdlString = kdl_str_from_cstr(cStr)
            self.parser = kdl_create_string_parser(kdlString, options)
        }
        #endif
    }

    #if Embedded && hasFeature(Embedded)
        func advance() throws(KDLReader.ReaderError) -> Event? {
            event = kdl_parser_next_event(self.parser)?.pointee
            guard let event else { return nil }

            switch event.event {
            case KDL_EVENT_START_NODE:
                return .startNode(String(kdlString: event.name))
            case KDL_EVENT_END_NODE:
                return .endNode
            case KDL_EVENT_ARGUMENT:
                return .argument(KDLValue(ckdlVal: event.value))
            case KDL_EVENT_PROPERTY:
                return .property(String(kdlString: event.name), KDLValue(ckdlVal: event.value))
            case KDL_EVENT_COMMENT:
                return .comment
            case KDL_EVENT_PARSE_ERROR:
                throw .parseError
            default:
                return nil
            }
        }
    #else
        func advance() throws(ParserError) -> Event? {
            event = kdl_parser_next_event(self.parser)?.pointee
            guard let event else { return nil }

            switch event.event {
            case KDL_EVENT_START_NODE:
                return .startNode(String(kdlString: event.name))
            case KDL_EVENT_END_NODE:
                return .endNode
            case KDL_EVENT_ARGUMENT:
                return .argument(KDLValue(ckdlVal: event.value))
            case KDL_EVENT_PROPERTY:
                return .property(String(kdlString: event.name), KDLValue(ckdlVal: event.value))
            case KDL_EVENT_COMMENT:
                return .comment
            case KDL_EVENT_PARSE_ERROR:
                throw .internalParseError(String(kdlString: event.value.string))
            default:
                return nil
            }
        }
    #endif
    
    deinit {
        kdl_destroy_parser(parser)
    }
}
