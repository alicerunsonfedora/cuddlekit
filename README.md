<img src="Sources/CuddleKit/CuddleKit.docc/Resources/CuddleKitLogo.svg" align=center width=128 />

# CuddleKit

With **CuddleKit**, you can work with structures represented in the Cuddly
Document Language (KDL) format. Create node trees from strings, or
serialize/deserialize existing structures.

> Important: CuddleKit is a work-in-progress library and is not production
> ready. Use at your own risk!

## Getting started

To start using CuddleKit, add it to your package's dependencies:

```swift
dependencies: [
  .package(url: "https://source.marquiskurt.net/marquiskurt/cuddlekit", from: "1.0.0")
]
```

> Note: To use this package in embedded environments, such as with
> PlaydateKit, add the `Embedded` package trait:
>
> ```swift
> dependencies: [
>   .package(
>     url: "https://source.marquiskurt.net/marquiskurt/cuddlekit",
>     from: "1.0.0",
>     traits: ["Embedded"])
> ]
> ```

## Usage

The most basic usage would include creating a KDL document tree from a
string value:

```swift
let myDocument =
  """
  manifest {
    version 1
    dependencies {
      libriven "https://pkg.archivists.guild/riven" version="^5.21.3"
      libart "https://git.archivists.guild/corelibs/art" branch="main"
    }
  }
  """

let reader = KDLReader()
let document = try reader.read(myDocument)

for node in document.nodes {
  ...
}

```

> Note: CuddleKit supports reading documents in KDLv2 and KDLv1. You can
> specify which version you want to read with the reader options:
>
> ```swift
> let reader = KDLReader()
> reader.options = [.parse_v2] // Only accept KDLv2 documents.
> ```

### Serialization and deserialization

CuddleKit supports a serialization/deserialization system akin to Swift's
Codable protocol. To leverage this behavior, conform to either
`KDLDeserializable`, `KDLSerializable`, or `KDLBidirectionalSerializable`,
based on your needs:

```swift
struct Person: KDLBidirectionalSerializable {
  var name: String
  var age: Int64

  init(from serializer: KDLSerializer) throws(KDLDeserializationError) {
    let arguments = try serializer.unkeyedDeserializationContainer()
    name = try arguments.deserialize(String.self)
    age = try arguments.deserialize(Int64.self)
  }

  func serialize(to serializer: KDLSerializer) throws(KDLSerializationError) {
    let arguments = try serializer.unkeyedSerializationContainer()
    try arguments.serialize(name)
    try arguments.serialize(age)
  }
}

struct ContactList: KDLBidirectionalSerializable {
  var contacts: [Person]

  init(from serializer: KDLSerializer) throws(KDLDeserializationError) {
    let children = try serializer.childDeserializationContainer()
    contacts = try children.deserialize(Person.self, forChildrenNamed: "contact")
  }

  func serialize(to serializer: KDLSerializer) throws(KDLSerializationError) {
    let children = try serializer.childSerializationContainer()
    for child in children {
      try children.serialize(child, withName: "contact")
    }
  }
}
```

You can use this type with `KDLSerializer` to deserialize a KDL document
into your structure:

```swift
let contactsDoc =
  """
  contacts {
    contact "Charles Takanaka" 42
    contact "Lorelei Weiss" 82
    contact "Renzo Nero" 32
  }
  """
let serializer = KDLSerializer()
let contactList = try serializer.deserialize(contactsDoc, as: ContactList.self)
for contact in contactList {
  print(contact.name, contact.age)
}
```

#### Why not adopt the Codable protocol?

While it could be theoretically possible to adopt the Codable protocol, it
wouldn't be supported under embedded environments due to language subset
restrictions. This might be improved in the future.

## License

CuddleKit is free and open-source software licensed under the MIT license.
For more information on your rights, refer to the LICENSE.txt file.

The CuddleKit logo is licensed under a [Creative Commons
Attribution-ShareAlike 4.0 International License][cc], with the original
logo created by Timothy Merritt (@timmybytes).

[cc]: http://creativecommons.org/licenses/by-sa/4.0/

CuddleKit is made possible by the following open-source software:

- [ckdl](https://github.com/tjol/ckdl): MIT License
