//
//  ValueSerialization.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

public protocol KDLValueDeserializable {
    init(kdlValue value: KDLValue) throws(KDLDeserializationError)
}

public protocol KDLValueSerializable {
    func serialize() throws(KDLSerializationError) -> KDLValue
}

public typealias KDLValueBidirectionalSerializable = KDLValueDeserializable & KDLValueSerializable

public final class KDLValueSerializationContainer {
    var value: KDLValue
    var serializationPath: KDLSerializationPath

    init(value: KDLValue, path serializationPath: KDLSerializationPath) {
        self.value = value
        self.serializationPath = serializationPath
    }

    func deserialize(_ type: String.Type) throws(KDLDeserializationError) -> String {
        switch value {
        case .untyped(.string(let stringValue)):
            return stringValue
        default:
            throw .typeValueMismatch(serializationPath)
        }
    }

    func deserialize(_ type: Bool.Type) throws(KDLDeserializationError) -> Bool {
        switch value {
        case .untyped(.boolean(let boolValue)):
            return boolValue
        default:
            throw .typeValueMismatch(serializationPath)
        }
    }

    func deserialize(_ type: Double.Type) throws(KDLDeserializationError) -> Double {
        switch value {
        case .untyped(.number(.floating(let doubleValue))):
            return doubleValue
        default:
            throw .typeValueMismatch(serializationPath)
        }
    }

    func deserialize(_ type: Int64.Type) throws(KDLDeserializationError) -> Int64 {
        switch value {
        case .untyped(.number(.integer(let intValue))):
            return intValue
        default:
            throw .typeValueMismatch(serializationPath)
        }
    }

    final func deserialize<T>(_ type: T.Type) throws(KDLDeserializationError) -> T
    where T: KDLValueDeserializable {
        try T(kdlValue: value)
    }

    func serialize(_ value: String) throws(KDLSerializationError) {
        self.value = try value.serialize()
    }

    func serialize(_ value: Bool) throws(KDLSerializationError) {
        self.value = try value.serialize()
    }

    func serialize(_ value: Int64) throws(KDLSerializationError) {
        self.value = try value.serialize()
    }

    func serialize(_ value: Double) throws(KDLSerializationError) {
        self.value = try value.serialize()
    }

    final func serialize<T>(_ value: T) throws(KDLSerializationError) where T: KDLValueSerializable {
        self.value = try value.serialize()
    }

    func finalize() -> KDLValue {
        return self.value
    }
}
