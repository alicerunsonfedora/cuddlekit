//
//  SerializationHelpers.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 16-04-2026.
//

struct NodeArrayContainer<T> {
    var values: [T]

    init(values: [T]) {
        self.values = values
    }
}

extension NodeArrayContainer: KDLDeserializable where T: KDLDeserializable {
    init(from serializer: KDLSerializer) throws(KDLDeserializationError) {
        self.values = []
        let container = try serializer.childDeserializationContainer()
        while container.canSerializeOrDeserializeNextChild {
            self.values.append(try container.deserializeNextChild(T.self))
        }
    }
}

extension NodeArrayContainer: KDLSerializable where T: KDLSerializable {
    func serialize(to serializer: KDLSerializer) throws(KDLSerializationError) {
        let container = try serializer.childSerializationContainer()
        for value in values {
            try container.serialize(value)
        }
    }
}

extension KDLNodeChildSerializationContainer {
    /// Deserialize an array of children nodes into the specified type.
    /// - Parameter type: The type to deserialize into.
    /// - Parameter name: The name of the child node to deserialize its children.
    public final func deserializeArray<T>(
        containing type: T.Type,
        forChildNamed name: String
    ) throws(KDLDeserializationError) -> [T] where T: KDLDeserializable {
        let array = try self.deserialize(NodeArrayContainer<T>.self, forChildNamed: name)
        return array.values
    }

    /// Deserialize an array of children nodes into the specified type if the child is present.
    /// - Parameter type: The type to deserialize into.
    /// - Parameter name: The name of the child node to deserialize its children.
    public final func deserializeArrayIfPresent<T>(
        containing type: T.Type,
        forChildNamed name: String
    ) throws(KDLDeserializationError) -> [T]? where T: KDLDeserializable {
        guard let array = try self.deserializeIfPresent(NodeArrayContainer<T>.self, forChildNamed: name) else {
            return nil
        }
        return array.values
    }
}
