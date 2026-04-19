//
//  CuddleKitError.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 17-04-2026.
//

/// An enumeration of errors that CuddleKit can throw.
///
/// This aggregating error type can be used when a function needs to throw errors of varying types, which can be
/// especially helpful for embedded environments where existential error types cannot be used.
public enum CuddleKitError: Error {
    /// An error occurred with the reader.
    case readerError(KDLReader.ReaderError)

    /// An error occurred during deserialization.
    case deserializationError(KDLDeserializationError)

    /// An error occurred during serialization.
    case serializationError(KDLSerializationError)
}

extension KDLSerializer {
    /// Deserialize the string as a KDL document to the specified type.
    /// - Parameter string: The source material to read as a KDL document and deserialize from.
    /// - Parameter type: The type to deserialize into.
    public final func deserialize<T>(_ string: String, as type: T.Type) throws(CuddleKitError) -> T
    where T: KDLDeserializable {
        let document = try makeDocument(string)
        return try deserializeDoc(document, as: type)
    }

    /// Deserialize the string as a KDL document to the specified array of types.
    /// - Parameter string: The source material to read as a KDL document and deserialize from.
    /// - Parameter type: The type to deserialize into.
    public final func deserializeArray<T>(_ string: String, containing type: T.Type) throws(CuddleKitError) -> [T]
    where T: KDLDeserializable {
        let document = try makeDocument(string)
        return try deserializeArrayDoc(document, as: type)
    }

    private func makeDocument(_ string: String) throws(CuddleKitError) -> KDLDocument {
        do {
            let reader = KDLReader()
            return try reader.read(string)
        } catch {
            throw .readerError(error)
        }
    }

    private final func deserializeDoc<T>(_ document: KDLDocument, as type: T.Type) throws(CuddleKitError) -> T
    where T: KDLDeserializable {
        do {
            return try self.deserialize(document, as: type)
        } catch {
            throw .deserializationError(error)
        }
    }

    private final func deserializeArrayDoc<T>(_ document: KDLDocument, as type: T.Type) throws(CuddleKitError) -> [T]
    where T: KDLDeserializable {
        do {
            return try self.deserializeArray(document, containing: type)
        } catch {
            throw .deserializationError(error)
        }
    }
}
