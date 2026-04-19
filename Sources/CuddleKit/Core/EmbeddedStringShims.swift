//
//  EmbeddedStringShims.swift
//  CuddleKit
//
//  Created by Marquis Kurt on 17-04-2026.
//

#if Embedded
    extension String.UTF8View: @retroactive Equatable, @retroactive Hashable {
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.elementsEqual(rhs)
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(0xFF as UInt8)
            for element in self {
                hasher.combine(element)
            }
        }
    }
    extension String {
        /// Whether the string has no content.
        public var isEmpty: Bool { utf8.isEmpty }

        /// Whether the string has any content.
        public var isNotEmpty: Bool { !isEmpty }

        public func equals(_ other: String) -> Bool {
            return self.utf8.elementsEqual(other.utf8)
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.utf8.elementsEqual(rhs.utf8)
        }

        public static func ~= (lhs: Self, rhs: Self) -> Bool {
            lhs == rhs
        }

        public func hasPrefix(_ prefix: Self) -> Bool {
            self.utf8.starts(with: prefix.utf8)
        }

        public func hasSuffix(_ suffix: Self) -> Bool {
            guard suffix.utf8.count <= self.utf8.count else { return false }
            return self.utf8.dropFirst(self.utf8.count - suffix.utf8.count).elementsEqual(suffix.utf8)
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(0xFF as UInt8)
            for element in self.utf8 {
                hasher.combine(element)
            }
        }

        public var hashValue: Int {
            var hasher = Hasher()
            self.hash(into: &hasher)
            return hasher.finalize()
        }

        /// Returns a copy of the string, removing the last character.
        ///
        /// If the string failed to drop the last character, it returns itself.
        public func droppingLastCharacter() -> Self {
            return self.droppingLast(k: 1)
        }

        /// Returns a copy of the string, removing the last _k_ characters.
        ///
        /// If the string failed to drop the last character, it returns itself.
        /// - Parameter k: The number of characters to drop.
        public func droppingLast(k characters: Int) -> Self {
            if isEmpty { return self }
            let utf8View = self.utf8
            let substring = utf8View.dropLast(characters)
            guard let newSelf = String(substring) else { return self }
            return newSelf
        }
    }

    extension Array where Element == String {
        public func firstIndex(of value: String) -> Index? {
            self.firstIndex { $0.equals(value) }
        }
    }

#endif
