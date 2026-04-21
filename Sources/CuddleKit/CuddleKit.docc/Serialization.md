# Serialize and deserialize KDL documents

## Overview

CuddleKit supports a serialization system akin to Swift's Codable protocol
that allows types you specify to be serialized into and/or deserialized
from KDL. This serialization system is supported under standard and
embedded Swift.

### Deserialize into types

Types that can be deserialized from KDL conform to the ``KDLDeserializable``
protocol and define an initializer that accepts a serializer:

```swift
struct Person: KDLDeserializable {
    var name: String
    var age: Int64

    init(from serializer: KDLSerializer) throws(KDLDeserializationError) {
        let args = try serializer.unkeyedDeserializationContainer()
        name = try args.deserialize(String.self)

        let props = try serializer.keyedDeserializationContainer()
        age = try args.deserialize(Int64.self, forKey: "age")
    }
}
```

### Serialize into KDL

Types can also be serialized to KDL by conforming to the ``KDLSerializable``
protocol:

```swift
extension Person: KDLSerializable {
    func serialize(to serializer: KDLSerializer) throws(KDLSerializationError) {
        let args = try serializer.unkeyedSerializationContainer()
        try args.serialize(name)

        let props = try serializer.keyedSerializationContainer()
        try props.serialize(age, forKey: "age")
    }
}
```

## Topics

### Serialize data

- ``KDLSerializer``
- ``KDLBidirectionalSerializable``
- ``KDLDeserializable``
- ``KDLSerializable``

### Serializing values

- ``KDLValueBidirectionalSerializable``
- ``KDLValueSerializable``
- ``KDLValueDeserializable``
- ``KDLValueSerializationContainer``

### Serialization containers

- ``KDLSerializationPath``
- ``KDLNodeArgumentSerializationContainer``
- ``KDLNodeChildSerializationContainer``
- ``KDLNodePropertySerializationContainer``

### Handling serialization errors

- ``KDLSerializationError``
- ``KDLDeserializationError``
