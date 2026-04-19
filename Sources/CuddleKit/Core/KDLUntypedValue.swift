//
//  KDLUntypedValue.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

import CKDL

public enum KDLUntypedValue: Equatable, Sendable {
    public enum KDLNumber: Equatable, Sendable {
        case integer(Int64)
        case floating(Double)
        case stringRepresentable(String)
    }

    case string(String)
    case number(KDLNumber)
    case boolean(Bool)

    init?(ckdlVal value: kdl_value) {
        switch value.type {
        case KDL_TYPE_STRING:
            self = .string(String(kdlString: value.string))
        case KDL_TYPE_BOOLEAN:
            self = .boolean(value.boolean)
        case KDL_TYPE_NUMBER:
            switch value.number.type {
            case KDL_NUMBER_TYPE_INTEGER:
                self = .number(.integer(value.number.integer))
            case KDL_NUMBER_TYPE_FLOATING_POINT:
                self = .number(.floating(value.number.floating_point))
            case KDL_NUMBER_TYPE_STRING_ENCODED:
                self = .number(.stringRepresentable(String(kdlString: value.number.string)))
            default:
                return nil
            }
        default:
            return nil
        }
    }
}
