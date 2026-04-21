//
//  NodeSerialization.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

/// A container used to serialize and deserialize unkeyed arguments in a KDL node.
///
/// Arguments are treated as an ordered list of values. When calling any of the serialization and deserialization
/// methods, the container automatically advances to the next available argument. To know whether the container can
/// keep deserializing arguments, use the ``canDeserializeNextArgument`` property.
public final class KDLNodeArgumentSerializationContainer {
    private var node: KDLNode
    private var serializationPath: KDLSerializationPath
    private var currentSerializationIndex: Int

    /// Whether the container can deserialize the next argument in the argument list.
    public var canDeserializeNextArgument: Bool {
        node.arguments.indices.contains(currentSerializationIndex)
    }

    init(node: KDLNode, path serializationPath: KDLSerializationPath) {
        self.node = node
        self.serializationPath = serializationPath
        self.currentSerializationIndex = 0
    }

    /// Deserializes the next argument in the argument list as a string.
    public func deserialize(_ type: String.Type) throws(KDLDeserializationError) -> String {
        guard node.arguments.indices.contains(currentSerializationIndex) else {
            throw .argumentIndexOutOfBounds(currentSerializationIndex, serializationPath)
        }
        let value = node.arguments[currentSerializationIndex]
        let deserializer = KDLValueSerializationContainer(value: value, path: serializationPath)
        let finalValue = try deserializer.deserialize(String.self)
        currentSerializationIndex += 1
        return finalValue
    }

    /// Deserializes the next argument in the argument list as a boolean value.
    public func deserialize(_ type: Bool.Type) throws(KDLDeserializationError) -> Bool {
        guard node.arguments.indices.contains(currentSerializationIndex) else {
            throw .argumentIndexOutOfBounds(currentSerializationIndex, serializationPath)
        }
        let value = node.arguments[currentSerializationIndex]
        let deserializer = KDLValueSerializationContainer(value: value, path: serializationPath)
        let finalValue = try deserializer.deserialize(Bool.self)
        currentSerializationIndex += 1
        return finalValue
    }

    /// Deserializes the next argument in the argument list as an integer value.
    public func deserialize(_ type: Int64.Type) throws(KDLDeserializationError) -> Int64 {
        guard node.arguments.indices.contains(currentSerializationIndex) else {
            throw .argumentIndexOutOfBounds(currentSerializationIndex, serializationPath)
        }
        let value = node.arguments[currentSerializationIndex]
        let deserializer = KDLValueSerializationContainer(value: value, path: serializationPath)
        let finalValue = try deserializer.deserialize(Int64.self)
        currentSerializationIndex += 1
        return finalValue
    }

    /// Deserializes the next argument in the argument list as a double-precision floating value.
    public func deserialize(_ type: Double.Type) throws(KDLDeserializationError) -> Double {
        guard node.arguments.indices.contains(currentSerializationIndex) else {
            throw .argumentIndexOutOfBounds(currentSerializationIndex, serializationPath)
        }
        let value = node.arguments[currentSerializationIndex]
        let deserializer = KDLValueSerializationContainer(value: value, path: serializationPath)
        let finalValue = try deserializer.deserialize(Double.self)
        currentSerializationIndex += 1
        return finalValue
    }

    /// Deserializes the next argument in the argument list as the specified type.
    /// - Parameter type: The type to deserialize the argument into.
    public final func deserialize<T>(_ type: T.Type) throws(KDLDeserializationError) -> T
    where T: KDLValueDeserializable {
        guard node.arguments.indices.contains(currentSerializationIndex) else {
            throw .argumentIndexOutOfBounds(currentSerializationIndex, serializationPath)
        }
        let value = node.arguments[currentSerializationIndex]
        let deserializer = KDLValueSerializationContainer(value: value, path: serializationPath)
        let finalValue = try deserializer.deserialize(type)
        currentSerializationIndex += 1
        return finalValue
    }

    /// Serialize the value as the next argument in the argument list.
    public func serialize(_ value: String) throws(KDLSerializationError) {
        let serializer = KDLValueSerializationContainer(value: .empty, path: serializationPath)
        try serializer.serialize(value)
        let finalValue = serializer.finalize()
        node.arguments.append(finalValue)
    }

    /// Serialize the value as the next argument in the argument list.
    public func serialize(_ value: Bool) throws(KDLSerializationError) {
        let serializer = KDLValueSerializationContainer(value: .empty, path: serializationPath)
        try serializer.serialize(value)
        let finalValue = serializer.finalize()
        node.arguments.append(finalValue)
    }

    /// Serialize the value as the next argument in the argument list.
    public func serialize(_ value: Int64) throws(KDLSerializationError) {
        let serializer = KDLValueSerializationContainer(value: .empty, path: serializationPath)
        try serializer.serialize(value)
        let finalValue = serializer.finalize()
        node.arguments.append(finalValue)
    }

    /// Serialize the value as the next argument in the argument list.
    public func serialize(_ value: Double) throws(KDLSerializationError) {
        let serializer = KDLValueSerializationContainer(value: .empty, path: serializationPath)
        try serializer.serialize(value)
        let finalValue = serializer.finalize()
        node.arguments.append(finalValue)
    }

    /// Serialize the value as the next argument in the argument list.
    public final func serialize<T>(_ value: T) throws(KDLSerializationError)
    where T: KDLValueSerializable {
        let serializer = KDLValueSerializationContainer(value: .empty, path: serializationPath)
        try serializer.serialize(value)
        let finalValue = serializer.finalize()
        node.arguments.append(finalValue)
    }

    func finalize() -> KDLNode {
        return self.node
    }
}
