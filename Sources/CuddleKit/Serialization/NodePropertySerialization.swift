//
//  NodePropertySerialization.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

public final class KDLNodePropertySerializationContainer {
    private var node: KDLNode
    private var serializationPath: KDLSerializationPath

    init(node: KDLNode, serializationPath: KDLSerializationPath) {
        self.node = node
        self.serializationPath = serializationPath
    }

    func getValue(for key: String) throws(KDLDeserializationError) -> KDLValue {
        #if Embedded && hasFeature(Embedded)
            guard let value = node.properties[key.utf8] else {
                throw .valueNotFound(serializationPath.appending(key))
            }
            return value
        #else
            guard let value = node.properties[key] else {
                throw .valueNotFound(serializationPath.appending(key))
            }
            return value
        #endif
    }

    func getValueOrNil(for key: String) -> KDLValue? {
        #if Embedded && hasFeature(Embedded)
            return node.properties[key.utf8]
        #else
            node.properties[key]
        #endif
    }

    func set(_ kdlValue: KDLValue, forKey key: String) {
        #if Embedded && hasFeature(Embedded)
            node.properties[key.utf8] = kdlValue
        #else
            node.properties[key] = kdlValue
        #endif
    }

    public func deserialize(_ type: String.Type, forKey key: String) throws(KDLDeserializationError) -> String {
        let value = try getValue(for: key)
        let container = KDLValueSerializationContainer(value: value, path: serializationPath.appending(key))
        return try container.deserialize(type)
    }

    public func deserialize(_ type: Bool.Type, forKey key: String) throws(KDLDeserializationError) -> Bool {
        let value = try getValue(for: key)
        let container = KDLValueSerializationContainer(value: value, path: serializationPath.appending(key))
        return try container.deserialize(type)
    }

    public func deserialize(_ type: Int64.Type, forKey key: String) throws(KDLDeserializationError) -> Int64 {
        let value = try getValue(for: key)
        let container = KDLValueSerializationContainer(value: value, path: serializationPath.appending(key))
        return try container.deserialize(type)
    }

    public func deserialize(_ type: Double.Type, forKey key: String) throws(KDLDeserializationError) -> Double {
        let value = try getValue(for: key)
        let container = KDLValueSerializationContainer(value: value, path: serializationPath.appending(key))
        return try container.deserialize(type)
    }

    public final func deserialize<T>(_ type: T.Type, forKey key: String) throws(KDLDeserializationError) -> T
    where T: KDLValueDeserializable {
        let value = try getValue(for: key)
        let container = KDLValueSerializationContainer(value: value, path: serializationPath.appending(key))
        return try container.deserialize(type)
    }

    public func deserializeIfPresent(_ type: String.Type, forKey key: String) throws(KDLDeserializationError) -> String?
    {
        guard let value = getValueOrNil(for: key) else { return nil }
        let container = KDLValueSerializationContainer(value: value, path: serializationPath.appending(key))
        return try container.deserialize(type)
    }

    public func deserializeIfPresent(_ type: Bool.Type, forKey key: String) throws(KDLDeserializationError) -> Bool? {
        guard let value = getValueOrNil(for: key) else { return nil }
        let container = KDLValueSerializationContainer(value: value, path: serializationPath.appending(key))
        return try container.deserialize(type)
    }

    public func deserializeIfPresent(_ type: Int64.Type, forKey key: String) throws(KDLDeserializationError) -> Int64? {
        guard let value = getValueOrNil(for: key) else { return nil }
        let container = KDLValueSerializationContainer(value: value, path: serializationPath.appending(key))
        return try container.deserialize(type)
    }

    public func deserializeIfPresent(_ type: Double.Type, forKey key: String) throws(KDLDeserializationError) -> Double?
    {
        guard let value = getValueOrNil(for: key) else { return nil }
        let container = KDLValueSerializationContainer(value: value, path: serializationPath.appending(key))
        return try container.deserialize(type)
    }

    public final func deserializeIfPresent<T>(_ type: T.Type, forKey key: String) throws(KDLDeserializationError) -> T?
    where T: KDLValueDeserializable {
        guard let value = getValueOrNil(for: key) else { return nil }
        let container = KDLValueSerializationContainer(value: value, path: serializationPath.appending(key))
        return try container.deserialize(type)
    }

    public func serialize(_ value: String, forKey key: String) throws(KDLSerializationError) {
        let container = KDLValueSerializationContainer(value: .empty, path: serializationPath.appending(key))
        try container.serialize(value)
        let kdlValue = container.finalize()
        set(kdlValue, forKey: key)
    }

    public func serialize(_ value: Bool, forKey key: String) throws(KDLSerializationError) {
        let container = KDLValueSerializationContainer(value: .empty, path: serializationPath.appending(key))
        try container.serialize(value)
        let kdlValue = container.finalize()
        set(kdlValue, forKey: key)
    }

    public func serialize(_ value: Int64, forKey key: String) throws(KDLSerializationError) {
        let container = KDLValueSerializationContainer(value: .empty, path: serializationPath.appending(key))
        try container.serialize(value)
        let kdlValue = container.finalize()
        set(kdlValue, forKey: key)
    }

    public func serialize(_ value: Double, forKey key: String) throws(KDLSerializationError) {
        let container = KDLValueSerializationContainer(value: .empty, path: serializationPath.appending(key))
        try container.serialize(value)
        let kdlValue = container.finalize()
        set(kdlValue, forKey: key)
    }

    public final func serialize<T>(_ value: T, forKey key: String) throws(KDLSerializationError)
    where T: KDLValueSerializable {
        let container = KDLValueSerializationContainer(value: .empty, path: serializationPath.appending(key))
        try container.serialize(value)
        let kdlValue = container.finalize()
        set(kdlValue, forKey: key)
    }

    func finalize() -> KDLNode {
        return self.node
    }
}
