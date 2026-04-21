//
//  ValueSerialization.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

/// A type that can be deserialized from a value represented in KDL.
public protocol KDLValueDeserializable {
    /// Create the type from a KDL value.
    /// - Parameter value: The value to deserialize.
    init(kdlValue value: KDLValue) throws(KDLDeserializationError)
}

/// A type that can be serialized into a value represented in KDL.
public protocol KDLValueSerializable {
    /// Serialize the current value into a KDL value.
    func serialize() throws(KDLSerializationError) -> KDLValue
}

/// A type that can be deserialize from/serialized to a value represented in KDL.
public typealias KDLValueBidirectionalSerializable = KDLValueDeserializable & KDLValueSerializable

/// A container used to serialize and deserialize values.
public final class KDLValueSerializationContainer {
    var value: KDLValue
    var serializationPath: KDLSerializationPath

    init(value: KDLValue, path serializationPath: KDLSerializationPath) {
        self.value = value
        self.serializationPath = serializationPath
    }

    /// Deserialize the current value as the specified type.
    /// - Parameter type: The type to deserialize to.
    public func deserialize(_ type: String.Type) throws(KDLDeserializationError) -> String {
        switch value {
        case .untyped(.string(let stringValue)):
            return stringValue
        default:
            throw .typeValueMismatch(serializationPath)
        }
    }

    /// Deserialize the current value as the specified type.
    /// - Parameter type: The type to deserialize to.
    public func deserialize(_ type: Bool.Type) throws(KDLDeserializationError) -> Bool {
        switch value {
        case .untyped(.boolean(let boolValue)):
            return boolValue
        default:
            throw .typeValueMismatch(serializationPath)
        }
    }

    /// Deserialize the current value as the specified type.
    /// - Parameter type: The type to deserialize to.
    public func deserialize(_ type: Double.Type) throws(KDLDeserializationError) -> Double {
        switch value {
        case .untyped(.number(.floating(let doubleValue))):
            return doubleValue
        default:
            throw .typeValueMismatch(serializationPath)
        }
    }

    /// Deserialize the current value as the specified type.
    /// - Parameter type: The type to deserialize to.
    public func deserialize(_ type: Int64.Type) throws(KDLDeserializationError) -> Int64 {
        switch value {
        case .untyped(.number(.integer(let intValue))):
            return intValue
        default:
            throw .typeValueMismatch(serializationPath)
        }
    }

    /// Deserialize the current value as the specified type.
    /// - Parameter type: The type to deserialize to.
    public final func deserialize<T>(_ type: T.Type) throws(KDLDeserializationError) -> T
    where T: KDLValueDeserializable {
        try T(kdlValue: value)
    }

    /// Serialize the current value into a KDL value.
    /// - Parameter value: The value to serialize.
    public func serialize(_ value: String) throws(KDLSerializationError) {
        self.value = try value.serialize()
    }

    /// Serialize the current value into a KDL value.
    /// - Parameter value: The value to serialize.
    public func serialize(_ value: Bool) throws(KDLSerializationError) {
        self.value = try value.serialize()
    }

    /// Serialize the current value into a KDL value.
    /// - Parameter value: The value to serialize.
    public func serialize(_ value: Int64) throws(KDLSerializationError) {
        self.value = try value.serialize()
    }

    /// Serialize the current value into a KDL value.
    /// - Parameter value: The value to serialize.
    public func serialize(_ value: Double) throws(KDLSerializationError) {
        self.value = try value.serialize()
    }

    /// Serialize the current value into a KDL value.
    /// - Parameter value: The value to serialize.
    public final func serialize<T>(_ value: T) throws(KDLSerializationError) where T: KDLValueSerializable {
        self.value = try value.serialize()
    }

    func finalize() -> KDLValue {
        return self.value
    }
}
