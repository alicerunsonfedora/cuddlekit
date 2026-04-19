//
//  DocumentSerialization.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

/// A type that can deserialize itself from a KDL representation.
public protocol KDLDeserializable {
    /// Creates a new instance by deserializing from the given serializer.
    /// - Parameter serializer: The serializer to read the data from.
    init(from serializer: KDLSerializer) throws(KDLDeserializationError)
}

/// A type that can serialize itself from a KDL representation.
public protocol KDLSerializable {
    /// Serialize the current instance with the given serializer.
    /// - Parameter serializer: The serializer to write the data to.
    func serialize(to serializer: KDLSerializer) throws(KDLSerializationError)
}

/// A type that can be serialized into and deserialized from an external KDL representation.
public typealias KDLBidirectionalSerializable = KDLDeserializable & KDLSerializable

/// A serializer used to serialize and deserialize types represented by a KDL document tree.
public final class KDLSerializer {
    /// The container used for unkeyed arguments.
    public typealias UnkeyedContainer = KDLNodeArgumentSerializationContainer

    /// The container used for keyed properties.
    public typealias KeyedContainer = KDLNodePropertySerializationContainer

    /// The container used for single values.
    public typealias SingleValueContainer = KDLValueSerializationContainer

    /// The container used for children.
    public typealias ChildContainer = KDLNodeChildSerializationContainer

    /// The name of the node being serialized and/or deserialized.
    public var name: String {
        get { currentNode?.name ?? "" }
        set { currentNode?.name = newValue }
    }

    private var currentNode: KDLNode?
    private var currentPath: KDLSerializationPath

    private var currentChildContainer: ChildContainer?
    private var currentKeyedContainer: KeyedContainer?
    private var currentUnkeyedContainer: UnkeyedContainer?

    /// Create an instance of a serializer.
    public init() {
        currentPath = KDLSerializationPath()
    }

    init(for node: KDLNode, at path: KDLSerializationPath = KDLSerializationPath()) {
        self.currentPath = path.appending(node.name)
        self.currentNode = node
    }

    /// Deserialize the KDL document into the specified type.
    /// - Parameter document: The KDL document to deserialize from.
    /// - Parameter type: The type to deserialize into.
    public final func deserialize<T>(_ document: KDLDocument, as type: T.Type) throws(KDLDeserializationError) -> T
    where T: KDLDeserializable {
        guard let tree = document.nodes.first else { throw .emptyDocument }
        currentNode = tree
        currentPath.push(tree.name)
        return try T(from: self)
    }

    /// Deserialize the KDL document into an array of items matching the specified type.
    /// - Parameter document: The KDL document to deserialize from.
    /// - Parameter type: The type to deserialize into.
    public final func deserializeArray<T>(
        _ document: KDLDocument,
        containing type: T.Type
    ) throws(KDLDeserializationError) -> [T]
    where T: KDLDeserializable {
        var items = [T]()
        for (index, node) in document.nodes.enumerated() {
            currentNode = node
            currentPath.push(index)
            let item = try T(from: self)
            items.append(item)
            currentPath.pop()
        }
        return items
    }

    /// Serialize a given item into a KDL document.
    /// - Parameter item: The item to serialize.
    public final func serialize<T>(_ item: T) throws(KDLSerializationError) -> KDLDocument where T: KDLSerializable {
        var document = KDLDocument(kdlVersion: 2, nodes: [])
        currentNode = KDLNode(named: "")
        currentPath.push(0)
        try item.serialize(to: self)
        finalizeNode()

        guard let currentNode else { throw .emptyDocument }
        document.nodes = [currentNode]
        return document
    }

    /// Serialize an array of items into a KDL document.
    /// - Parameter items: The items to serialize.
    public final func serializeArray<T>(_ items: [T]) throws(KDLSerializationError) -> KDLDocument
    where T: KDLSerializable {
        var document = KDLDocument(kdlVersion: 2, nodes: [])
        var currentNodeIndex = 0
        for item in items {
            currentNode = KDLNode(named: "")
            currentPath.push(currentNodeIndex)
            try item.serialize(to: self)
            finalizeNode()

            guard let currentNode else { throw .emptyDocument }
            document.nodes.append(currentNode)
            currentNodeIndex += 1
        }
        return document
    }

    /// Create a container for deserializing unkeyed arguments.
    public func unkeyedDeserializationContainer() throws(KDLDeserializationError) -> UnkeyedContainer {
        guard let currentNode else { throw .valueNotFound(currentPath) }
        return KDLNodeArgumentSerializationContainer(node: currentNode, path: currentPath)
    }

    /// Create a container for deserializing keyed properties.
    public func keyedDeserializationContainer() throws(KDLDeserializationError) -> KeyedContainer {
        guard let currentNode else { throw .valueNotFound(currentPath) }
        return KDLNodePropertySerializationContainer(node: currentNode, serializationPath: currentPath)
    }

    /// Create a container for deserializing children.
    public func childDeserializationContainer() throws(KDLDeserializationError) -> ChildContainer {
        guard let currentNode else { throw .valueNotFound(currentPath) }
        return KDLNodeChildSerializationContainer(node: currentNode, serializationPath: currentPath)
    }

    /// Create a container for serializing unkeyed arguments.
    public func unkeyedSerializationContainer() throws(KDLSerializationError) -> UnkeyedContainer {
        guard let currentNode else { throw .valueNotFound(currentPath) }
        let container = KDLNodeArgumentSerializationContainer(node: currentNode, path: currentPath)
        self.currentUnkeyedContainer = container
        return container
    }

    /// Create a container for serializing keyed properties.
    public func keyedSerializationContainer() throws(KDLSerializationError) -> KeyedContainer {
        guard let currentNode else { throw .valueNotFound(currentPath) }
        let container = KDLNodePropertySerializationContainer(node: currentNode, serializationPath: currentPath)
        self.currentKeyedContainer = container
        return container
    }

    /// Create a container for serializing children.
    public func childSerializationContainer() throws(KDLSerializationError) -> ChildContainer {
        guard let currentNode else { throw .valueNotFound(currentPath) }
        let container = KDLNodeChildSerializationContainer(node: currentNode, serializationPath: currentPath)
        self.currentChildContainer = container
        return container
    }

    // MARK: - Internal Components

    final func deserializeCurrentNode<T>(as type: T.Type) throws(KDLDeserializationError) -> T
    where T: KDLDeserializable {
        let node = try T(from: self)
        finalizeNode()
        return node
    }

    final func serializeCurrentNode<T>(_ value: T) throws(KDLSerializationError) -> KDLNode where T: KDLSerializable {
        try value.serialize(to: self)
        finalizeNode()
        guard let currentNode else {
            throw .valueNotFound(currentPath)
        }
        return currentNode
    }

    func finalizeNode() {
        if let nodeArgs = currentUnkeyedContainer?.finalize() {
            currentNode?.arguments = nodeArgs.arguments
        }
        currentUnkeyedContainer = nil

        if let nodeProps = currentKeyedContainer?.finalize() {
            currentNode?.properties = nodeProps.properties
        }
        currentKeyedContainer = nil

        if let nodeChildren = currentChildContainer?.finalize() {
            currentNode?.children = nodeChildren.children
        }
        currentKeyedContainer = nil
    }
}
