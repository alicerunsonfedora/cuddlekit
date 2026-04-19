//
//  Fixtures.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

import CuddleKit

enum Bughorse: String, KDLValueBidirectionalSerializable {
    case thorax, ocellus, chrysalis
}

struct SampleArgumentNode: KDLBidirectionalSerializable {
    var horse: Bughorse
    var initialStat: Int64

    init(horse: Bughorse, initialStat: Int64) {
        self.horse = horse
        self.initialStat = initialStat
    }

    init(from serializer: KDLSerializer) throws(KDLDeserializationError) {
        let container = try serializer.unkeyedDeserializationContainer()
        self.horse = try container.deserialize(Bughorse.self)
        self.initialStat = try container.deserialize(Int64.self)
    }

    func serialize(to serializer: KDLSerializer) throws(KDLSerializationError) {
        serializer.name = "character"
        let container = try serializer.unkeyedSerializationContainer()
        try container.serialize(horse)
        try container.serialize(initialStat)
    }
}

struct SamplePropertyNode: Equatable, KDLBidirectionalSerializable {
    var horse: Bughorse
    var initialStat: Int64
    var comment: String?

    init(horse: Bughorse, initialStat: Int64, comment: String? = nil) {
        self.horse = horse
        self.initialStat = initialStat
        self.comment = comment
    }

    init(from serializer: KDLSerializer) throws(KDLDeserializationError) {
        let container = try serializer.keyedDeserializationContainer()
        self.horse = try container.deserialize(Bughorse.self, forKey: "horse")
        self.initialStat = try container.deserialize(Int64.self, forKey: "initialStat")
        self.comment = try container.deserializeIfPresent(String.self, forKey: "comment")
    }

    func serialize(to serializer: KDLSerializer) throws(KDLSerializationError) {
        serializer.name = "character"
        let container = try serializer.keyedSerializationContainer()
        try container.serialize(horse, forKey: "horse")
        try container.serialize(initialStat, forKey: "initialStat")
        if let comment {
            try container.serialize(comment, forKey: "comment")
        }
    }
}

struct SamplePropertyNodeWithChild: KDLDeserializable {
    var name: String
    var character: SamplePropertyNode

    init(name: String, character: SamplePropertyNode) {
        self.name = name
        self.character = character
    }

    init(from serializer: KDLSerializer) throws(KDLDeserializationError) {
        let arguments = try serializer.unkeyedDeserializationContainer()
        name = try arguments.deserialize(String.self)

        let childContainer = try serializer.childDeserializationContainer()
        character = try childContainer.deserialize(SamplePropertyNode.self, forChildNamed: "character")
    }
}

struct ChildArraySample: Equatable, KDLDeserializable {
    var players: [SamplePropertyNode]

    init(players: [SamplePropertyNode]) {
        self.players = players
    }

    init(from serializer: KDLSerializer) throws(KDLDeserializationError) {
        let childContainer = try serializer.childDeserializationContainer()
        players = try childContainer.deserialize(SamplePropertyNode.self, forChildrenNamed: "player")
    }
}

struct SampleManifest: Equatable, KDLBidirectionalSerializable {
    struct Version: Equatable, KDLBidirectionalSerializable {
        var version: Int64

        init(version: Int64) {
            self.version = version
        }

        init(from serializer: KDLSerializer) throws(KDLDeserializationError) {
            let arguments = try serializer.unkeyedDeserializationContainer()
            version = try arguments.deserialize(Int64.self)
        }

        func serialize(to serializer: KDLSerializer) throws(KDLSerializationError) {
            let arguments = try serializer.unkeyedSerializationContainer()
            try arguments.serialize(version)
        }
    }

    var version: Version

    init(version: Version) {
        self.version = version
    }

    init(from serializer: KDLSerializer) throws(KDLDeserializationError) {
        let childContainer = try serializer.childDeserializationContainer()
        version = try childContainer.deserialize(Version.self, forChildNamed: "version")
    }

    func serialize(to serializer: KDLSerializer) throws(KDLSerializationError) {
        let childContainer = try serializer.childSerializationContainer()
        try childContainer.serialize(version, withName: "version")
    }
}

struct PersonSample: Equatable, KDLBidirectionalSerializable {
    var name: String
    var displayName: String?
    var age: Int64

    init(name: String, displayName: String? = nil, age: Int64) {
        self.name = name
        self.displayName = displayName
        self.age = age
    }

    init(from serializer: KDLSerializer) throws(KDLDeserializationError) {
        self.name = serializer.name

        let arguments = try serializer.unkeyedDeserializationContainer()
        self.age = try arguments.deserialize(Int64.self)

        let properties = try serializer.keyedDeserializationContainer()
        self.displayName = try properties.deserializeIfPresent(String.self, forKey: "displayName")
    }

    func serialize(to serializer: KDLSerializer) throws(KDLSerializationError) {
        serializer.name = self.name
        let arguments = try serializer.unkeyedSerializationContainer()
        try arguments.serialize(age)

        let properties = try serializer.keyedSerializationContainer()
        if let displayName {
            try properties.serialize(displayName, forKey: "displayName")
        }
    }
}

struct ContactsSample: Equatable, KDLBidirectionalSerializable {
    var contacts: [PersonSample]

    init(contacts: [PersonSample]) {
        self.contacts = contacts
    }

    init(from serializer: KDLSerializer) throws(KDLDeserializationError) {
        let childContainer = try serializer.childDeserializationContainer()
        var contacts = [PersonSample]()
        while childContainer.canSerializeOrDeserializeNextChild {
            let person = try childContainer.deserializeNextChild(PersonSample.self)
            contacts.append(person)
        }
        self.contacts = contacts
    }

    func serialize(to serializer: KDLSerializer) throws(KDLSerializationError) {
        serializer.name = "contacts"
        let childContainer = try serializer.childSerializationContainer()
        for contact in contacts {
            try childContainer.serialize(contact)
        }
    }
}

struct PackageManifest: Equatable, KDLBidirectionalSerializable {
    struct Dependency: Equatable, KDLBidirectionalSerializable {
        enum CheckoutType: Equatable {
            case branch(String)
            case version(String)
        }

        var name: String
        var url: String
        var checkoutType: CheckoutType

        init(name: String, url: String, checkoutType: CheckoutType) {
            self.name = name
            self.url = url
            self.checkoutType = checkoutType
        }

        static func dependency(name: String, url: String, branch: String) -> Self {
            Dependency(name: name, url: url, checkoutType: .branch(branch))
        }

        static func dependency(name: String, url: String, from version: String) -> Self {
            Dependency(name: name, url: url, checkoutType: .version(version))
        }

        init(from serializer: KDLSerializer) throws(KDLDeserializationError) {
            name = serializer.name

            let arguments = try serializer.unkeyedDeserializationContainer()
            url = try arguments.deserialize(String.self)

            let properties = try serializer.keyedDeserializationContainer()
            let branchKind = try properties.deserializeIfPresent(String.self, forKey: "branch")
            let versionKind = try properties.deserializeIfPresent(String.self, forKey: "version")
            switch (branchKind, versionKind) {
            case (nil, let .some(version)):
                checkoutType = .version(version)
            case (let .some(branch), nil):
                checkoutType = .branch(branch)
            default:
                throw .valueNotFound(KDLSerializationPath())
            }
        }
    
        func serialize(to serializer: KDLSerializer) throws(KDLSerializationError) {
            serializer.name = name

            let arguments = try serializer.unkeyedSerializationContainer()
            try arguments.serialize(url)

            let properties = try serializer.keyedSerializationContainer()
            switch checkoutType {
            case .branch(let string):
                try properties.serialize(string, forKey: "branch")
            case .version(let string):
                try properties.serialize(string, forKey: "version")
            }
        }
    }

    struct DependencyContainer: Equatable, KDLBidirectionalSerializable {
        var dependencies: [Dependency]

        init(dependencies: [Dependency]) {
            self.dependencies = dependencies
        }

        init(from serializer: KDLSerializer) throws(KDLDeserializationError) {
            var dependencies = [Dependency]()
            let childContainer = try serializer.childDeserializationContainer()
            while childContainer.canSerializeOrDeserializeNextChild {
                let dependency = try childContainer.deserializeNextChild(Dependency.self)
                dependencies.append(dependency)
            }
            self.dependencies = dependencies
        }

        func serialize(to serializer: KDLSerializer) throws(KDLSerializationError) {
            let childContainer = try serializer.childSerializationContainer()
            for dependency in dependencies {
                try childContainer.serialize(dependency)
            }
        }
    }

    var manifestVersion: Int64
    var dependencies: [Dependency]

    init(version manifestVersion: Int64, dependencies: [Dependency]) {
        self.manifestVersion = manifestVersion
        self.dependencies = dependencies
    }

    init(from serializer: KDLSerializer) throws(KDLDeserializationError) {
        let childContainer = try serializer.childDeserializationContainer()

        let version = try childContainer.deserialize(SampleManifest.Version.self, forChildNamed: "version")
        self.manifestVersion = version.version

        let depGroup = try childContainer.deserialize(DependencyContainer.self, forChildNamed: "dependencies")
        self.dependencies = depGroup.dependencies
    }

    func serialize(to serializer: KDLSerializer) throws(KDLSerializationError) {
        serializer.name = "manifest"

        let childContainer = try serializer.childSerializationContainer()
        let version = SampleManifest.Version(version: self.manifestVersion)
        try childContainer.serialize(version, withName: "version")

        let depGroup = DependencyContainer(dependencies: dependencies)
        try childContainer.serialize(depGroup, withName: "dependencies")
    }
}
