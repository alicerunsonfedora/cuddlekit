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

public enum KDLValue: Equatable, Sendable {
    case typed(KDLTypedValue)
    case untyped(KDLUntypedValue)

    public init?(ckdlVal value: kdl_value) {
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
