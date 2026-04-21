# ``CuddleKit/KDLNodePropertySerializationContainer``

## Topics

### Deserialize known properties

- ``deserialize(_:forKey:)->Bool``
- ``deserialize(_:forKey:)->Double``
- ``deserialize(_:forKey:)->Int64``
- ``deserialize(_:forKey:)->String``
- ``deserialize(_:forKey:)->T``

### Deserialize unknown properties

- ``deserializeIfPresent(_:forKey:)->Bool?``
- ``deserializeIfPresent(_:forKey:)->Double?``
- ``deserializeIfPresent(_:forKey:)->Int64?``
- ``deserializeIfPresent(_:forKey:)->String?``
- ``deserializeIfPresent(_:forKey:)->T?``

### Serialize properties

- ``serialize(_:forKey:)-(Bool,_)``
- ``serialize(_:forKey:)-(Double,_)``
- ``serialize(_:forKey:)-(Int64,_)``
- ``serialize(_:forKey:)-(String,_)``
- ``serialize(_:forKey:)-(T,_)``
