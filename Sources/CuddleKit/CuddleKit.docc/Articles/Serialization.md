# Serialize and deserialize KDL documents

Use serialization APIs to transform KDL document data into custom types
you provide.

## Overview

CuddleKit supports a serialization system akin to Swift's Codable protocol
that allows types you specify to be serialized into and/or deserialized
from KDL. This serialization system is supported under standard and
embedded Swift.

To serialize and deserialize types, the ``KDLSerializer`` class is used.
The serializer is provided as an argument to types that conform to the
``KDLDeserializable`` and ``KDLSerializable`` protocols, respectively,
which provides facilities for creating containers used to parse KDL node
trees.

```swift
struct PackageManifest: KDLDeserializable { ... }

let manifestDocument =
    """
    manifest {
        version 1

        dependencies {
            libriven "https://pkg.archivist.guild/riven" version="^5.21.3"
            libart "https://git.archivist.guild/core/art" branch="main"
        }
    }
    """

let serializer = KDLSerializer()
let manifest = try serializer.deserialize(manifestDocument, as: PackageManifest.self)
for dependency in manifest.dependencies { ... }
```

### Deserialize KDL into types

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

The above example assumes that a `Person` as represented in a KDL node
looks similar to:

```kdl
person "John Appleseed" age=51
```

### Serialize types into KDL

Types can also be serialized to KDL by conforming to the ``KDLSerializable``
protocol. The example from above demonstrates serialization back into a
KDL node:

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

### Value representation

KDL supports four value types: strings, boolean values, integers,
and double-precision floating values. Values also support custom type
annotations to specify the value's type. Some types may need to be
represented as raw KDL values, rather than nodes. The
``KDLValueSerializable`` and ``KDLValueDeserializable`` protocols allow
types to be represented with values. These behave similarly to their node
counterparts, although they exchange a KDL value rather than a serializer.

```swift
enum Bughorse: String, KDLValueDeserializable {
    case thorax, ocellus, pharynx, chrysalis

    init(kdlValue value: KDLValue) throws(KDLDeserializationError) {
        switch value {
        case .untyped(.string(let strValue)):
            switch strValue {
            case "thorax":
                self = .thorax
            case "chrysalis":
                self = .chrysalis
            case "pharynx":
                self = .pharynx
            case "ocellus":
                self = .ocellus
            default:
                throw .typeValueMismatch(KDLSerializationPath())
            }
        default:
            throw .typeValueMismatch(KDLSerializationPath())
        }
    }
}
```

> Tip: In non-embedded contexts, types that conform to `RawRepresentable`
> can automatically conform to ``KDLValueDeserializable`` and
> ``KDLValueSerializable``.

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
