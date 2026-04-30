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
public protocol KDLTypedValueRepresentable {
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

extension FixedWidthInteger where Self: KDLValueSerializable, Self: KDLTypedValueRepresentable {
    public func serialize() throws(KDLSerializationError) -> KDLValue {
        .typed(KDLTypedValue(annotation: Self.kdlPreferredAnnotation, value: .number(.integer(Int64(self)))))
    }
}

extension FixedWidthInteger where Self: KDLValueDeserializable, Self: KDLTypedValueRepresentable {
    public init(kdlValue value: KDLValue) throws (KDLDeserializationError) {
        switch value {
        case .typed(let typedValue):
            guard Self.typeMatches(typedValue.annotation) else {
                throw .typeValueMismatch(KDLSerializationPath())
            }
            guard case .number(.integer(let intValue)) = typedValue.value else {
                throw .typeValueMismatch(KDLSerializationPath())
            }
            self = Self.init(intValue)
        default:
            throw .typeValueMismatch(KDLSerializationPath())
        }
    }
}

extension BinaryFloatingPoint where Self: KDLValueSerializable, Self: KDLTypedValueRepresentable {
    public func serialize() throws(KDLSerializationError) -> KDLValue {
        .typed(KDLTypedValue(annotation: Self.kdlPreferredAnnotation, value: .number(.floating(Double(self)))))
    }
}

extension BinaryFloatingPoint where Self: KDLValueDeserializable, Self: KDLTypedValueRepresentable {
    public init(kdlValue value: KDLValue) throws (KDLDeserializationError) {
        switch value {
        case .typed(let typedValue):
            guard Self.typeMatches(typedValue.annotation) else {
                throw .typeValueMismatch(KDLSerializationPath())
            }
            guard case .number(.floating(let floatValue)) = typedValue.value else {
                throw .typeValueMismatch(KDLSerializationPath())
            }
            self = Self.init(floatValue)
        default:
            throw .typeValueMismatch(KDLSerializationPath())
        }
    }
}

extension Int: KDLTypedValueRepresentable, KDLValueBidirectionalSerializable {
    public static let kdlTypedAnnotations = ["int"]
    public static let kdlPreferredAnnotation = "int"
}

extension Int8: KDLTypedValueRepresentable, KDLValueBidirectionalSerializable {
    public static let kdlTypedAnnotations = ["i8", "int8"]
    public static let kdlPreferredAnnotation = "int8"
}

extension Int16: KDLTypedValueRepresentable, KDLValueBidirectionalSerializable {
    public static let kdlTypedAnnotations = ["i16", "int16"]
    public static let kdlPreferredAnnotation = "int16"
}

extension Int32: KDLTypedValueRepresentable, KDLValueBidirectionalSerializable {
    public static let kdlTypedAnnotations = ["i32", "int32"]
    public static let kdlPreferredAnnotation = "int32"
}

@available(macOS 15.0, iOS 18.0, *)
extension Int128: KDLTypedValueRepresentable, KDLValueBidirectionalSerializable {
    public static let kdlTypedAnnotations = ["i128", "int128"]
    public static let kdlPreferredAnnotation = "int128"
}

extension UInt: KDLTypedValueRepresentable, KDLValueBidirectionalSerializable {
    public static let kdlTypedAnnotations = ["uint"]
    public static let kdlPreferredAnnotation = "uint"
}

extension UInt8: KDLTypedValueRepresentable, KDLValueBidirectionalSerializable {
    public static let kdlTypedAnnotations = ["u8", "uint8"]
    public static let kdlPreferredAnnotation = "uint8"
}

extension UInt16: KDLTypedValueRepresentable, KDLValueBidirectionalSerializable {
    public static let kdlTypedAnnotations = ["u16", "uint16"]
    public static let kdlPreferredAnnotation = "uint16"
}

extension UInt32: KDLTypedValueRepresentable, KDLValueBidirectionalSerializable {
    public static let kdlTypedAnnotations = ["u32", "uint32"]
    public static let kdlPreferredAnnotation = "uint32"
}

@available(macOS 15.0, iOS 18.0, *)
extension UInt128: KDLTypedValueRepresentable, KDLValueBidirectionalSerializable {
    public static let kdlTypedAnnotations = ["u128", "uint128"]
    public static let kdlPreferredAnnotation = "uint128"
}

extension Float: KDLTypedValueRepresentable, KDLValueBidirectionalSerializable {
    public static let kdlTypedAnnotations = ["float", "float32", "f32"]
    public static let kdlPreferredAnnotation = "float"
}

extension Float16: KDLTypedValueRepresentable, KDLValueBidirectionalSerializable {
    public static let kdlTypedAnnotations = ["float16", "f16"]
    public static let kdlPreferredAnnotation = "float16"
}
