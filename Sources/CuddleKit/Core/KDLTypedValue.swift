//
//  KDLTypedValue.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

/// A type representing a KDL value with a type annotation.
public struct KDLTypedValue: Equatable, Sendable {
    /// The annotation that suggests the type of the value.
    public var annotation: String

    /// The value pending a more specified type.
    public var value: KDLUntypedValue

    public init(annotation: String, value: KDLUntypedValue) {
        self.annotation = annotation
        self.value = value
    }
}
