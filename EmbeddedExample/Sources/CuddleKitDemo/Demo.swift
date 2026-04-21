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
}

struct Player: KDLDeserializable {
    var name: String
    var character: Bughorse
    var initialStat: Int64

    init(name: String, character: Bughorse, initialStat: Int64) {
        self.name = name
        self.character = character
        self.initialStat = initialStat
    }

    init(from serializer: KDLSerializer) throws(KDLDeserializationError) {
        let arguments = try serializer.unkeyedDeserializationContainer()
        name = try arguments.deserialize(String.self)

        let properties = try serializer.keyedDeserializationContainer()
        character = try properties.deserialize(Bughorse.self, forKey: "character")
        initialStat = try properties.deserialize(Int64.self, forKey: "stat")
    }
}
