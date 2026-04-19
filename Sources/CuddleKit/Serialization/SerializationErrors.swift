//
//  SerializationErrors.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

public enum KDLDeserializationError: Error, Equatable {
    case emptyDocument
    case valueNotFound(KDLSerializationPath)
    case typeValueMismatch(KDLSerializationPath)
    case argumentIndexOutOfBounds(Int, KDLSerializationPath)
}

extension KDLDeserializationError {
    static func rawTypeValueMismatch() -> Self {
        .typeValueMismatch(KDLSerializationPath())
    }
}

public enum KDLSerializationError: Error {
    case emptyDocument
    case valueNotFound(KDLSerializationPath)
    case argumentIndexOutOfBounds(Int, KDLSerializationPath)
}
