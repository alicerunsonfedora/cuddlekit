//
//  KDLValue.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 11-04-2026.
//

import CKDL

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

// MARK: - ckdl interop

extension String {
    init(kdlString: kdl_str) {
        self.init(cString: kdlString.data)
    }
}

extension kdl_value {
    private typealias Applesauce = kdl_value.__Unnamed_union___Anonymous_field2

    init(_ kdlValue: KDLValue) {
        var kdlValueType: kdl_type
        var kdlAnnotation = kdl_str()
        var applesauce = Applesauce()
        switch kdlValue {
        case .typed(let typedValue):
            typedValue.annotation.withCString { ptr in
                kdlAnnotation = kdl_str_from_cstr(ptr)
            }
            (kdlValueType, applesauce) = Self.getUntypedValue(typedValue.value)
        case .untyped(let untypedValue):
            (kdlValueType, applesauce) = Self.getUntypedValue(untypedValue)
        }

        self = kdl_value(type: kdlValueType, type_annotation: kdlAnnotation, applesauce)
    }

    private static func getUntypedValue(_ value: KDLUntypedValue) -> (kdl_type, Applesauce) {
        var kdlValueType: kdl_type
        var applesauce = Applesauce()
    
        switch value {
        case .string(let stringValue):
            kdlValueType = KDL_TYPE_STRING
            stringValue.withCString { ptr in
                let kdlString = kdl_str_from_cstr(ptr)
                applesauce = .init(string: kdlString)
            }
        case .number(.integer(let intValue)):
            kdlValueType = KDL_TYPE_NUMBER
            applesauce = .init(number: .init(type: KDL_NUMBER_TYPE_INTEGER, .init(integer: intValue)))
        case .number(.floating(let double)):
            kdlValueType = KDL_TYPE_NUMBER
            applesauce = .init(number: .init(type: KDL_NUMBER_TYPE_FLOATING_POINT, .init(floating_point: double)))
        case .number(.stringRepresentable(let repr)):
            kdlValueType = KDL_TYPE_NUMBER
            repr.withCString { ptr in
                let kdlReprString = kdl_str_from_cstr(repr)
                applesauce = .init(
                    number: .init(type: KDL_NUMBER_TYPE_STRING_ENCODED, .init(string: kdlReprString))
                )
            }
        case .boolean(let boolValue):
            kdlValueType = KDL_TYPE_BOOLEAN
            applesauce = .init(boolean: boolValue)
        }

        return (kdlValueType, applesauce)
    }
}
