//
//  KDLUntypedValue.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

import CKDL

/// A type representing an untyped value in KDL.
public enum KDLUntypedValue: Equatable, Sendable {
    /// A type representing a number in KDL.
    public enum KDLNumber: Equatable, Sendable {
        /// The number as an integer type.
        case integer(Int64)

        /// The number as a double-precision floating point type.
        case floating(Double)

        /// The number as a value represented by a string.
        case stringRepresentable(String)
    }

    /// The value represented as a string.
    case string(String)

    /// The value represented as a number.
    case number(KDLNumber)

    /// The value represented as a boolean.
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
