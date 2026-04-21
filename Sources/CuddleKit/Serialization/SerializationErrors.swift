//
//  SerializationErrors.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

/// An enumeration of the errors that can occur when attempting to deserialize a KDL document into a given type.
public enum KDLDeserializationError: Error, Equatable {
    /// The document is empty.
    case emptyDocument

    /// No value exists at the given path.
    case valueNotFound(KDLSerializationPath)

    /// The type of value at the given path doesn't match the expected type.
    case typeValueMismatch(KDLSerializationPath)

    /// The argument's index is out of bounds.
    case argumentIndexOutOfBounds(Int, KDLSerializationPath)
}

extension KDLDeserializationError {
    static func rawTypeValueMismatch() -> Self {
        .typeValueMismatch(KDLSerializationPath())
    }
}

/// An enumeration of the errors that can occur when attempting to serialize a type into a KDL document.
public enum KDLSerializationError: Error {
    /// The document is empty.
    case emptyDocument

    /// No value exists at the given path.
    case valueNotFound(KDLSerializationPath)

    /// The argument's index is out of bounds.
    case argumentIndexOutOfBounds(Int, KDLSerializationPath)
}
