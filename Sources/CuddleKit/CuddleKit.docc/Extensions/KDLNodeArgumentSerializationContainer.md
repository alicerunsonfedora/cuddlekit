# ``CuddleKit/KDLNodeArgumentSerializationContainer``

## Overview

Node arguments are treated as an ordered list of values. Calling any of the
`deserialize` methods will automatically advance to the next available
argument. For example, consider the following node:

```
mynode "a" 10 #false
```

Deserializing the arguments in `mynode` would use the following:

```swift
let myStrnValue = try container.deserialize(String.self) // "a"
let myIntgValue = try container.deserialize(Int64.self) // 10
let myBoolValue = try container.deserialize(Bool.self) // false
```

### Deserializing repeated arguments

There may be instances where repeatedly deserializing an array of arguments
is needed. All of the deserialization methods can throw an error when there
are no arguments left to parse. To avoid accidental errors, it might be
preferable to validate against the ``canDeserializeNextArgument`` property,
which indicates whether the container can keep deserializing arguments.

```swift
var allNames = [String]()
while container.canDeserializeNextArgument {
    let name = try container.deserialize(String.self)
    allNames.append(name)
}
```

### Serializing arguments

Since the number of arguments can be arbitrary when serializing data, there
are no additional checks when adding arguments to serialize. Serializing a
type as an argument will automatically append it to the list of existing
arguments.

```swift
for name in allNames {
    try container.serialize(name)
}
```

## Topics

### Deserialize arguments

- ``canDeserializeNextArgument``
- ``deserialize(_:)->String``
- ``deserialize(_:)->Bool``
- ``deserialize(_:)->Double``
- ``deserialize(_:)->Int64``
- ``deserialize(_:)->T``

### Serialize arguments

- ``serialize(_:)-(String)``
- ``serialize(_:)-(Bool)``
- ``serialize(_:)-(Double)``
- ``serialize(_:)-(Int64)``
- ``serialize(_:)-(T)``
