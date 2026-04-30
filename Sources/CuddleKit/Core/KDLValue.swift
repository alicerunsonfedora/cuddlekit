//
//  KDLValue.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 11-04-2026.
//

import CKDL

extension String {
    init(kdlString: kdl_str) {
        self.init(cString: kdlString.data)
    }
}

/// An enumeration representing an individual value represented by KDL.
public enum KDLValue: Equatable, Sendable {
    /// A value with a type annotation attached.
    case typed(KDLTypedValue)

    /// An untyped value.
    case untyped(KDLUntypedValue)

    init?(ckdlVal value: kdl_value) {
        guard let untypedValue = KDLUntypedValue(ckdlVal: value) else { return nil }
        if value.type_annotation.len > 0 {
            self = .typed(KDLTypedValue(annotation: String(kdlString: value.type_annotation), value: untypedValue))
        } else {
            self = .untyped(untypedValue)
        }
    }

    public init(_ string: String, ofType annotation: String? = nil) {
        guard let annotation else {
            self = .untyped(.string(string))
            return
        }
        self = .typed(KDLTypedValue(annotation: annotation, value: .string(string)))
    }

    public init(_ integer: Int64, ofType annotation: String? = nil) {
        guard let annotation else {
            self = .untyped(.number(.integer(integer)))
            return
        }
        self = .typed(KDLTypedValue(annotation: annotation, value: .number(.integer(integer))))
    }

    public init(_ double: Double, ofType annotation: String? = nil) {
        guard let annotation else {
            self = .untyped(.number(.floating(double)))
            return
        }
        self = .typed(KDLTypedValue(annotation: annotation, value: .number(.floating(double))))
    }

    public init(_ boolean: Bool, ofType annotation: String? = nil) {
        guard let annotation else {
            self = .untyped(.boolean(boolean))
            return
        }
        self = .typed(KDLTypedValue(annotation: annotation, value: .boolean(boolean)))
    }
}

extension KDLValue {
    static var empty: Self {
        .untyped(.string(""))
    }
}
