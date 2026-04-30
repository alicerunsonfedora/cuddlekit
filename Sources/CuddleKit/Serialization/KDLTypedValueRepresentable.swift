//
//  KDLIntegerRepresentable.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 30-04-2026.
//

/// A type that can be represented as KDL value with an associated type.
///
/// This type automatically gains conformances with ``KDLValueSerializable`` and ``KDLValueDeserializable``, adding type
/// checks before serializing and/or deserializing the value.
public protocol KDLTypedValueRepresentable: KDLValueSerializable, KDLValueDeserializable {
    /// The annotations that represent the current type.
    static var kdlTypedAnnotations: [String] { get }

    /// The preferred annotation for when this type is serialized.
    static var kdlPreferredAnnotation: String { get }
}

extension KDLTypedValueRepresentable {
    static func typeMatches(_ typeValue: String) -> Bool {
        let views = kdlTypedAnnotations.map { $0.utf8 }
        let preferredView = kdlPreferredAnnotation.utf8
        var hasMatch = preferredView.elementsEqual(typeValue.utf8)
        for view in views {
            if !typeValue.utf8.elementsEqual(view) {
                continue
            }
            hasMatch = true
        }
        return hasMatch
    }
}

extension FixedWidthInteger where Self: KDLTypedValueRepresentable {
    public func serialize() throws(KDLSerializationError) -> KDLValue {
        KDLValue(Int64(self), ofType: Self.kdlPreferredAnnotation)
    }
}

extension FixedWidthInteger where Self: KDLTypedValueRepresentable {
    public init(kdlValue value: KDLValue) throws (KDLDeserializationError) {
        switch value {
        case .typed(let typedValue):
            guard Self.typeMatches(typedValue.annotation) else {
                throw .typeValueMismatch(KDLSerializationPath())
            }
            switch typedValue.value {
            case .number(.integer(let intValue)):
                self = Self.init(intValue)
            case .string("max"):
                self = .max
            case .string("min"):
                self = .min
            default:
                throw .typeValueMismatch(KDLSerializationPath())
            }
        default:
            throw .typeValueMismatch(KDLSerializationPath())
        }
    }
}

extension BinaryFloatingPoint where Self: KDLTypedValueRepresentable {
    public func serialize() throws(KDLSerializationError) -> KDLValue {
        KDLValue(Double(self), ofType: Self.kdlPreferredAnnotation)
    }
}

extension BinaryFloatingPoint where Self: KDLTypedValueRepresentable {
    public init(kdlValue value: KDLValue) throws (KDLDeserializationError) {
        switch value {
        case .typed(let typedValue):
            guard Self.typeMatches(typedValue.annotation) else {
                throw .typeValueMismatch(KDLSerializationPath())
            }
            switch typedValue.value {
            case let .number(.floating(floatValue)):
                self = Self.init(floatValue)
            case .string("min"):
                self = .leastNonzeroMagnitude
            case .string("nan"):
                self = .nan
            case .string("pi"):
                self = .pi
            case .string("infinity"), .string("inf"):
                self = .infinity
            default:
                throw .typeValueMismatch(KDLSerializationPath())
            }
        default:
            throw .typeValueMismatch(KDLSerializationPath())
        }
    }
}

extension Int: KDLTypedValueRepresentable {
    public static let kdlTypedAnnotations = ["int"]
    public static let kdlPreferredAnnotation = "int"
}

extension Int8: KDLTypedValueRepresentable {
    public static let kdlTypedAnnotations = ["i8", "int8"]
    public static let kdlPreferredAnnotation = "int8"
}

extension Int16: KDLTypedValueRepresentable {
    public static let kdlTypedAnnotations = ["i16", "int16"]
    public static let kdlPreferredAnnotation = "int16"
}

extension Int32: KDLTypedValueRepresentable {
    public static let kdlTypedAnnotations = ["i32", "int32"]
    public static let kdlPreferredAnnotation = "int32"
}

@available(macOS 15.0, iOS 18.0, *)
extension Int128: KDLTypedValueRepresentable {
    public static let kdlTypedAnnotations = ["i128", "int128"]
    public static let kdlPreferredAnnotation = "int128"
}

extension UInt: KDLTypedValueRepresentable {
    public static let kdlTypedAnnotations = ["uint"]
    public static let kdlPreferredAnnotation = "uint"
}

extension UInt8: KDLTypedValueRepresentable {
    public static let kdlTypedAnnotations = ["u8", "uint8"]
    public static let kdlPreferredAnnotation = "uint8"
}

extension UInt16: KDLTypedValueRepresentable {
    public static let kdlTypedAnnotations = ["u16", "uint16"]
    public static let kdlPreferredAnnotation = "uint16"
}

extension UInt32: KDLTypedValueRepresentable {
    public static let kdlTypedAnnotations = ["u32", "uint32"]
    public static let kdlPreferredAnnotation = "uint32"
}

@available(macOS 15.0, iOS 18.0, *)
extension UInt128: KDLTypedValueRepresentable {
    public static let kdlTypedAnnotations = ["u128", "uint128"]
    public static let kdlPreferredAnnotation = "uint128"
}

extension Float: KDLTypedValueRepresentable {
    public static let kdlTypedAnnotations = ["float", "float32", "f32"]
    public static let kdlPreferredAnnotation = "float"
}

extension Float16: KDLTypedValueRepresentable {
    public static let kdlTypedAnnotations = ["float16", "f16"]
    public static let kdlPreferredAnnotation = "float16"
}
