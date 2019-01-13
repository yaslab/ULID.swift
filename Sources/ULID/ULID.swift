//
//  ULID.swift
//  ULID
//
//  Created by Yasuhiro Hatta on 2019/01/11.
//  Copyright © 2019 yaslab. All rights reserved.
//

import Foundation

public typealias ulid_t = uuid_t

public struct ULID: Hashable, Equatable, CustomStringConvertible {

    public private(set) var ulid: ulid_t = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

    public init(ulid: ulid_t) {
        self.ulid = ulid
    }

    public init?(ulidData data: Data) {
        guard data.count == 16 else {
            return nil
        }
        withUnsafeMutableBytes(of: &ulid) {
            $0.copyBytes(from: data)
        }
    }

    public init?(ulidString string: String) {
        guard string.count == 26, let data = Data(base32Encoded: "000000" + string) else {
            return nil
        }
        self.init(ulidData: data.dropFirst(4))
    }

    public init(timestamp: Date = Date()) {
        withUnsafeMutableBytes(of: &ulid) { (buffer) in
            var millisec = UInt64(timestamp.timeIntervalSince1970 * 1000.0).bigEndian
            withUnsafeBytes(of: &millisec) {
                for i in 0 ..< 6 {
                    buffer[i] = $0[2 + i]
                }
            }
            let range = UInt8.min ... .max
            for i in 6 ..< 16 {
                buffer[i] = UInt8.random(in: range)
            }
        }
    }

    public var ulidData: Data {
        return withUnsafeBytes(of: ulid) {
            return Data(buffer: $0.bindMemory(to: UInt8.self))
        }
    }

    public var ulidString: String {
        return String((Data(count: 4) + ulidData).base32EncodedString().dropFirst(6))
    }

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

    public static func ==(lhs: ULID, rhs: ULID) -> Bool {
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

    public var description: String {
        return ulidString
    }

}

extension ULID: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)

        guard let ulid = ULID(ulidString: string) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "Attempted to decode ULID from invalid ULID string."))
        }

        self = ulid
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.ulidString)
    }

}
