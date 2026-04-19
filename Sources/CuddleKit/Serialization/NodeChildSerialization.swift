//
//  NodeChildSerialization.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 16-04-2026.
//

public final class KDLNodeChildSerializationContainer {
    private var node: KDLNode
    private var serializationPath: KDLSerializationPath
    private var currentChildIndex = 0

    public var canSerializeOrDeserializeNextChild: Bool {
        node.children.indices.contains(currentChildIndex)
    }

    init(node: KDLNode, serializationPath: KDLSerializationPath) {
        self.node = node
        self.serializationPath = serializationPath
        self.currentChildIndex = 0
    }

    public final func deserialize<T>(
        _ type: T.Type,
        forChildNamed childName: String
    ) throws(KDLDeserializationError) -> T where T: KDLDeserializable {
        guard let childNode = node.children.first(where: { $0.name == childName }) else {
            throw .valueNotFound(serializationPath.appending(childName))
        }
        let serializer = KDLSerializer(for: childNode, at: serializationPath)
        return try serializer.deserializeCurrentNode(as: type)
    }

    public final func deserialize<T>(
        _ type: T.Type,
        forChildrenNamed childName: String
    ) throws(KDLDeserializationError) -> [T] where T: KDLDeserializable {
        let children = node.children.filter { $0.name == childName }
        guard !children.isEmpty else {
            throw .valueNotFound(serializationPath.appending(childName))
        }
        var result = [T]()
        for (index, child) in children.enumerated() {
            let serializer = KDLSerializer(for: child, at: serializationPath.appending("\(childName).\(index)"))
            let item = try serializer.deserializeCurrentNode(as: type)
            result.append(item)
        }
        return result
    }

    public final func deserializeNextChild<T>(_ type: T.Type) throws(KDLDeserializationError) -> T
    where T: KDLDeserializable {
        guard node.children.indices.contains(currentChildIndex) else {
            throw .argumentIndexOutOfBounds(currentChildIndex, serializationPath)
        }
        let childNode = node.children[currentChildIndex]
        let serializer = KDLSerializer(for: childNode, at: serializationPath.appending(currentChildIndex))
        let result = try T(from: serializer)
        currentChildIndex += 1
        return result
    }

    public final func deserializeIfPresent<T>(
        _ type: T.Type,
        forChildNamed childName: String
    ) throws(KDLDeserializationError) -> T? where T: KDLDeserializable {
        guard let childNode = node.children.first(where: { $0.name == childName }) else {
            return nil
        }
        let serializer = KDLSerializer(for: childNode, at: serializationPath)
        return try serializer.deserializeCurrentNode(as: type)
    }

    public final func deserializeIfPresent<T>(
        _ type: T.Type,
        forChildrenNamed childName: String
    ) throws(KDLDeserializationError) -> [T]? where T: KDLDeserializable {
        let children = node.children.filter { $0.name == childName }
        guard !children.isEmpty else {
            return nil
        }
        var result = [T]()
        for (index, child) in children.enumerated() {
            let serializer = KDLSerializer(for: child, at: serializationPath.appending("\(childName).\(index)"))
            let item = try serializer.deserializeCurrentNode(as: type)
            result.append(item)
        }
        return result
    }

    public final func serialize<T>(_ value: T, withName name: String? = nil) throws(KDLSerializationError)
    where T: KDLSerializable {
        let serializer = KDLSerializer(
            for: KDLNode(named: name ?? ""),
            at: serializationPath.appending(currentChildIndex)
        )
        let finalValue = try serializer.serializeCurrentNode(value)
        node.children.append(finalValue)
        currentChildIndex += 1
    }

    func finalize() -> KDLNode {
        self.node
    }
}
