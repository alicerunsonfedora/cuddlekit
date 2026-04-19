//
//  CoreTypeExtensions.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 15-04-2026.
//

extension String: KDLValueBidirectionalSerializable {
    public init(kdlValue value: KDLValue) throws(KDLDeserializationError) {
        switch value {
        case .untyped(.string(let stringValue)):
            self = stringValue
        default:
            throw .rawTypeValueMismatch()
        }
    }

    public func serialize() throws(KDLSerializationError) -> KDLValue {
        .untyped(.string(self))
    }
}

extension Bool: KDLValueBidirectionalSerializable {
    public init(kdlValue value: KDLValue) throws(KDLDeserializationError) {
        switch value {
        case .untyped(.boolean(let boolValue)):
            self = boolValue
        default:
            throw .rawTypeValueMismatch()
        }
    }

    public func serialize() throws(KDLSerializationError) -> KDLValue {
        .untyped(.boolean(self))
    }
}

extension Double: KDLValueBidirectionalSerializable {
    public init(kdlValue value: KDLValue) throws(KDLDeserializationError) {
        switch value {
        case .untyped(.number(.floating(let doubleValue))):
            self = doubleValue
        default:
            throw .rawTypeValueMismatch()
        }
    }

    public func serialize() throws(KDLSerializationError) -> KDLValue {
        .untyped(.number(.floating(self)))
    }
}

extension Int64: KDLValueBidirectionalSerializable {
    public init(kdlValue value: KDLValue) throws(KDLDeserializationError) {
        switch value {
        case .untyped(.number(.integer(let intValue))):
            self = intValue
        default:
            throw .rawTypeValueMismatch()
        }
    }

    public func serialize() throws(KDLSerializationError) -> KDLValue {
        .untyped(.number(.integer(self)))
    }
}

#if !Embedded && !hasFeature(Embedded)
    extension KDLUntypedValue: ExpressibleByStringLiteral {
        public init(stringLiteral value: StringLiteralType) {
            self = .string(value)
        }
    }

    extension KDLUntypedValue: ExpressibleByFloatLiteral {
        public init(floatLiteral value: FloatLiteralType) {
            self = .number(.floating(value))
        }
    }

    extension KDLUntypedValue: ExpressibleByIntegerLiteral {
        public init(integerLiteral value: IntegerLiteralType) {
            self = .number(.integer(Int64(value)))
        }
    }

    extension KDLUntypedValue: ExpressibleByBooleanLiteral {
        public init(booleanLiteral value: BooleanLiteralType) {
            self = .boolean(value)
        }
    }

    extension KDLValue: ExpressibleByStringLiteral {
        public init(stringLiteral value: StringLiteralType) {
            self = .untyped(.string(value))
        }
    }

    extension KDLValue: ExpressibleByFloatLiteral {
        public init(floatLiteral value: FloatLiteralType) {
            self = .untyped(.number(.floating(value)))
        }
    }

    extension KDLValue: ExpressibleByIntegerLiteral {
        public init(integerLiteral value: IntegerLiteralType) {
            self = .untyped(.number(.integer(Int64(value))))
        }
    }

    extension KDLValue: ExpressibleByBooleanLiteral {
        public init(booleanLiteral value: BooleanLiteralType) {
            self = .untyped(.boolean(value))
        }
    }

    extension RawRepresentable where RawValue: KDLValueDeserializable, Self: KDLValueDeserializable {
        public init(kdlValue value: KDLValue) throws(KDLDeserializationError) {
            let rawValue = try RawValue(kdlValue: value)
            guard let newSelf = Self.init(rawValue: rawValue) else {
                throw .rawTypeValueMismatch()
            }
            self = newSelf
        }
    }

    extension RawRepresentable where RawValue: KDLValueSerializable, Self: KDLValueSerializable {
        public func serialize() throws(KDLSerializationError) -> KDLValue {
            try rawValue.serialize()
        }
    }
#endif
