//
//  ULID.swift
//  ULID
//
//  Created by Yasuhiro Hatta on 2019/01/11.
//  Copyright © 2019 yaslab. All rights reserved.
//

import Foundation

public typealias ulid_t = uuid_t

/// Universally Unique Lexicographically Sortable Identifier.
public struct ULID: Hashable, Equatable, Comparable, CustomStringConvertible, Sendable {

    public private(set) var ulid: ulid_t = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

    /// Create a ULID from a `ulid_t`.
    public init(ulid: ulid_t) {
        self.ulid = ulid
    }

    /// Create a ULID from a data.
    public init?(ulidData data: Data) {
        guard data.count == 16 else {
            return nil
        }
        withUnsafeMutableBytes(of: &ulid) {
            $0.copyBytes(from: data)
        }
    }

    /// Create a ULID from a string.
    public init?(ulidString string: String) {
        guard string.utf8.count == 26, let data = Data(base32Encoded: "000000" + string) else {
            return nil
        }
        withUnsafeMutableBytes(of: &ulid) {
            $0.copyBytes(from: data.dropFirst(4))
        }
    }
    
    /// Create a ULID from a timestamp and a random part.
    ///
    /// - Parameters:
    ///   - timestamp: Specify the timestamp as `Date`.
    ///   - data: Data representation of the random part of the ULID.
    /// - Returns: **nil** if the `data` is less than 80 bits or 10 bytes in size.
    public init?(timestamp: Date = Date(), randomPartData data: Data){
        let randomDataInBytes = 10
        guard data.count >= randomDataInBytes else { return nil }
        
        withUnsafeMutableBytes(of: &ulid) { (buffer) in
            var i = 0
            var millisec = UInt64(timestamp.timeIntervalSince1970 * 1000.0).bigEndian
            withUnsafeBytes(of: &millisec) {
                for j in 2 ..< 8 {
                    buffer[i] = $0[j]
                    i += 1
                }
            }
            var randomPart:Data = Data()
            if data.count > randomDataInBytes{
                randomPart = data.prefix(randomDataInBytes)
            }else{
                randomPart = data
            }
            
            withUnsafeBytes(of: &randomPart) {
                for j in 0 ..< 10 {
                    buffer[i] = $0[j]
                    i += 1
                }
            }
        }
    }

    /// Create a ULID with the given timestamp and random number generator.
    public init<T: RandomNumberGenerator>(timestamp: Date, generator: inout T) {
        withUnsafeMutableBytes(of: &ulid) { (buffer) in
            var i = 0
            var millisec = UInt64(timestamp.timeIntervalSince1970 * 1000.0).bigEndian
            withUnsafeBytes(of: &millisec) {
                for j in 2 ..< 8 {
                    buffer[i] = $0[j]
                    i += 1
                }
            }
            var random16 = UInt16.random(in: .min ... .max, using: &generator).bigEndian
            withUnsafeBytes(of: &random16) {
                for j in 0 ..< 2 {
                    buffer[i] = $0[j]
                    i += 1
                }
            }
            var random64 = UInt64.random(in: .min ... .max, using: &generator).bigEndian
            withUnsafeBytes(of: &random64) {
                for j in 0 ..< 8 {
                    buffer[i] = $0[j]
                    i += 1
                }
            }
        }
    }

    /// Create a ULID with the given timestamp.
    public init(timestamp: Date = Date()) {
        var g = SystemRandomNumberGenerator()
        self.init(timestamp: timestamp, generator: &g)
    }

    /// Returns a raw binary data.
    public var ulidData: Data {
        return withUnsafeBytes(of: ulid) {
            return Data(buffer: $0.bindMemory(to: UInt8.self))
        }
    }

    /// Returns a string created from the ULID.
    public var ulidString: String {
        return withUnsafeBytes(of: ulid) {
            var data = Data(count: 4)
            data.append($0.bindMemory(to: UInt8.self))
            return String(data.base32EncodedString().dropFirst(6))
        }
    }

    /// Returns the timestamp part of the ULID.
    public var timestamp: Date {
        return withUnsafeBytes(of: ulid) { (buffer) in
            var millisec: UInt64 = 0
            withUnsafeMutableBytes(of: &millisec) {
                for i in 0 ..< 6 {
                    $0[2 + i] = buffer[i]
                }
            }
            return Date(timeIntervalSince1970: TimeInterval(millisec.bigEndian) / 1000.0)
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ulid.0)
        hasher.combine(ulid.1)
        hasher.combine(ulid.2)
        hasher.combine(ulid.3)
        hasher.combine(ulid.4)
        hasher.combine(ulid.5)
        hasher.combine(ulid.6)
        hasher.combine(ulid.7)
        hasher.combine(ulid.8)
        hasher.combine(ulid.9)
        hasher.combine(ulid.10)
        hasher.combine(ulid.11)
        hasher.combine(ulid.12)
        hasher.combine(ulid.13)
        hasher.combine(ulid.14)
        hasher.combine(ulid.15)
    }

    public static func == (lhs: ULID, rhs: ULID) -> Bool {
        return lhs.ulid.0 == rhs.ulid.0
            && lhs.ulid.1 == rhs.ulid.1
            && lhs.ulid.2 == rhs.ulid.2
            && lhs.ulid.3 == rhs.ulid.3
            && lhs.ulid.4 == rhs.ulid.4
            && lhs.ulid.5 == rhs.ulid.5
            && lhs.ulid.6 == rhs.ulid.6
            && lhs.ulid.7 == rhs.ulid.7
            && lhs.ulid.8 == rhs.ulid.8
            && lhs.ulid.9 == rhs.ulid.9
            && lhs.ulid.10 == rhs.ulid.10
            && lhs.ulid.11 == rhs.ulid.11
            && lhs.ulid.12 == rhs.ulid.12
            && lhs.ulid.13 == rhs.ulid.13
            && lhs.ulid.14 == rhs.ulid.14
            && lhs.ulid.15 == rhs.ulid.15
    }

    public static func < (lhs: ULID, rhs: ULID) -> Bool {
        if lhs.ulid.0 != rhs.ulid.0 { return lhs.ulid.0 < rhs.ulid.0 }
        if lhs.ulid.1 != rhs.ulid.1 { return lhs.ulid.1 < rhs.ulid.1 }
        if lhs.ulid.2 != rhs.ulid.2 { return lhs.ulid.2 < rhs.ulid.2 }
        if lhs.ulid.3 != rhs.ulid.3 { return lhs.ulid.3 < rhs.ulid.3 }
        if lhs.ulid.4 != rhs.ulid.4 { return lhs.ulid.4 < rhs.ulid.4 }
        if lhs.ulid.5 != rhs.ulid.5 { return lhs.ulid.5 < rhs.ulid.5 }
        if lhs.ulid.6 != rhs.ulid.6 { return lhs.ulid.6 < rhs.ulid.6 }
        if lhs.ulid.7 != rhs.ulid.7 { return lhs.ulid.7 < rhs.ulid.7 }
        if lhs.ulid.8 != rhs.ulid.8 { return lhs.ulid.8 < rhs.ulid.8 }
        if lhs.ulid.9 != rhs.ulid.9 { return lhs.ulid.9 < rhs.ulid.9 }
        if lhs.ulid.10 != rhs.ulid.10 { return lhs.ulid.10 < rhs.ulid.10 }
        if lhs.ulid.11 != rhs.ulid.11 { return lhs.ulid.11 < rhs.ulid.11 }
        if lhs.ulid.12 != rhs.ulid.12 { return lhs.ulid.12 < rhs.ulid.12 }
        if lhs.ulid.13 != rhs.ulid.13 { return lhs.ulid.13 < rhs.ulid.13 }
        if lhs.ulid.14 != rhs.ulid.14 { return lhs.ulid.14 < rhs.ulid.14 }
        return lhs.ulid.15 < rhs.ulid.15
    }

    public var description: String {
        return ulidString
    }

    /// A factory that generates monotonically increasing ULIDs
    public final class MonotonicFactory {
        private var lastTime: UInt64 = 0
        private var lastRandom: String?
        private var generator: SystemRandomNumberGenerator
        
        public init(generator: SystemRandomNumberGenerator = SystemRandomNumberGenerator()) {
            self.generator = generator
        }
        
        /// Generate a new ULID that's guaranteed to be monotonically increasing
        public func create(timestamp: Date = Date()) -> ULID {
            let currentTime: UInt64 = UInt64(timestamp.timeIntervalSince1970 * 1000.0)
            
            if let lastRandomPart: String = lastRandom, currentTime <= lastTime {
                // Need to increment the random part
                let incrementedRandom = incrementBase32(lastRandomPart)
                if let incrementedULID: ULID = ULID(ulidString: encodeTime(lastTime) + incrementedRandom) {
                    lastRandom = incrementedRandom
                    return incrementedULID
                }
                // If increment failed, fall through to generate new random
            }
            
            // Generate new ULID normally
            let newULID: ULID = ULID(timestamp: timestamp, generator: &generator)
            lastTime = currentTime
            lastRandom = String(newULID.ulidString.dropFirst(10))
            return newULID
        }
        
        private func encodeTime(_ timestamp: UInt64) -> String {
            var timeChars: [Character] = [Character](repeating: "0", count: 10)
            var time: UInt64 = timestamp
            
            for i: Int in (0..<10).reversed() {
                timeChars[i] = Base32.crockfordsEncodingTable[Int(time % 32)].ascii
                time /= 32
            }
            
            return String(timeChars)
        }
        
        private func incrementBase32(_ str: String) -> String {
            var chars: [String.Element] = Array(str)
            let encodingTable: String = String(bytes: Base32.crockfordsEncodingTable, encoding: .ascii)!
            
            for i in (0..<chars.count).reversed() {
                let currentChar: String.Element = chars[i]
                if let currentIndex: String.Index = encodingTable.firstIndex(of: currentChar) {
                    if currentIndex < encodingTable.index(before: encodingTable.endIndex) {
                        // Normal increment case
                        chars[i] = encodingTable[encodingTable.index(after: currentIndex)]
                        return String(chars)
                    }
                    // Handle overflow by continuing to next position
                    chars[i] = encodingTable.first!
                    continue
                }
                // If character not found in encoding table, something is wrong
                fatalError("Invalid base32 character in ULID")
            }
            // If we get here, we've overflowed the entire random part
            return String(repeating: String(encodingTable.first!), count: str.count)
        }
    }

}

extension ULID: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)

        guard let ulid = ULID(ulidString: string) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Attempted to decode ULID from invalid ULID string."
                )
            )
        }

        self = ulid
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.ulidString)
    }

}

// Add ASCII conversion helper
private extension UInt8 {
    var ascii: Character {
        return Character(UnicodeScalar(self))
    }
}
