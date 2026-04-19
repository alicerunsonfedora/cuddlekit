//
//  KDLTypedValue.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

public struct KDLTypedValue: Equatable, Sendable {
    public var annotation: String
    public var value: KDLUntypedValue

    public init(annotation: String, value: KDLUntypedValue) {
        self.annotation = annotation
        self.value = value
    }
}
