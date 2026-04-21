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
}

extension KDLValue {
    static var empty: Self {
        .untyped(.string(""))
    }
}
