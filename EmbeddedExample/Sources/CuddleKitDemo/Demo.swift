//
//  Demo.swift
//  PDUIKitDemo
//
//  Created by Marquis Kurt on 17-04-2026.
//

import CuddleKit

enum Bughorse: String, KDLValueDeserializable {
    case thorax, chrysalis, pharynx, ocellus

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

    var displayName: String {
        switch self {
        case .chrysalis: "Chrysalis"
        case .thorax: "Thorax"
        case .ocellus: "Ocellus"
        case .pharynx: "Pharynx"
        }
    }
}

struct PlayerContainer: KDLDeserializable {
    var players: [Player]

    init(from serializer: KDLSerializer) throws(KDLDeserializationError) {
        var players = [Player]()
        let children = try serializer.childDeserializationContainer()
        while children.canSerializeOrDeserializeNextChild {
            players.append(try children.deserializeNextChild(Player.self))
        }
        self.players = players
    }
}

struct Player: KDLDeserializable {
    var username: String
    var name: String
    var character: Bughorse
    var initialStat: Int

    var hasDisplayName: Bool {
        !name.utf8.elementsEqual(username.utf8)
    }

    init(from serializer: KDLSerializer) throws(KDLDeserializationError) {
        username = serializer.name

        let arguments = try serializer.unkeyedDeserializationContainer()
        if arguments.canDeserializeNextArgument {
            name = try arguments.deserialize(String.self)
        } else {
            // Provide a fallback if there's no argument.
            name = serializer.name
        }

        let properties = try serializer.keyedDeserializationContainer()
        character = try properties.deserialize(Bughorse.self, forKey: "character")
        if let initialStat = try properties.deserializeIfPresent(Int.self, forKey: "stat") {
            self.initialStat = initialStat
        } else {
            self.initialStat = 5
        }
    }
}
