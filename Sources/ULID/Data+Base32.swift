//
//  Data+Base32.swift
//  ULID
//
//  Created by Yasuhiro Hatta on 2019/01/11.
//

import Foundation

enum Base32 {

    static let crockfordsEncodingTable: [Character] = Array("0123456789ABCDEFGHJKMNPQRSTVWXYZ")

    static let crockfordsDecodingTable: [Character: UInt8] = [
        "0": 0x00, "O": 0x00, "o": 0x00,
        "1": 0x01, "I": 0x01, "i": 0x01, "L": 0x01, "l": 0x01,
        "2": 0x02,
        "3": 0x03,
        "4": 0x04,
        "5": 0x05,
        "6": 0x06,
        "7": 0x07,
        "8": 0x08,
        "9": 0x09,
        "A": 0x0a, "a": 0x0a,
        "B": 0x0b, "b": 0x0b,
        "C": 0x0c, "c": 0x0c,
        "D": 0x0d, "d": 0x0d,
        "E": 0x0e, "e": 0x0e,
        "F": 0x0f, "f": 0x0f,
        "G": 0x10, "g": 0x10,
        "H": 0x11, "h": 0x11,
        "J": 0x12, "j": 0x12,
        "K": 0x13, "k": 0x13,
        "M": 0x14, "m": 0x14,
        "N": 0x15, "n": 0x15,
        "P": 0x16, "p": 0x16,
        "Q": 0x17, "q": 0x17,
        "R": 0x18, "r": 0x18,
        "S": 0x19, "s": 0x19,
        "T": 0x1a, "t": 0x1a,
        "V": 0x1b, "v": 0x1b,
        "W": 0x1c, "w": 0x1c,
        "X": 0x1d, "x": 0x1d,
        "Y": 0x1e, "y": 0x1e,
        "Z": 0x1f, "z": 0x1f
    ]

}

extension Data {

    /// Decode Crockford's Base32
    init?(base32Encoded base32String: String, using table: [Character: UInt8] = Base32.crockfordsDecodingTable) {
        let str: [Character]
        if let index = base32String.firstIndex(of: "=") {
            str = Array(base32String[base32String.startIndex ..< index])
        } else {
            str = Array(base32String)
        }

        let div = str.count / 8
        let mod = str.count % 8

        var buffer = Data()

        do {
            func unwrap(_ value: UInt8?) throws -> UInt8 {
                guard let value = value else { throw NSError() }
                return value
            }

            for i in 0 ..< div {
                let offset = 8 * i
                try buffer.append(unwrap(table[str[offset + 0]]) << 3 | unwrap(table[str[offset + 1]]) >> 2)
                try buffer.append(unwrap(table[str[offset + 1]]) << 6 | unwrap(table[str[offset + 2]]) << 1 | unwrap(table[str[offset + 3]]) >> 4)
                try buffer.append(unwrap(table[str[offset + 3]]) << 4 | unwrap(table[str[offset + 4]]) >> 1)
                try buffer.append(unwrap(table[str[offset + 4]]) << 7 | unwrap(table[str[offset + 5]]) << 2 | unwrap(table[str[offset + 6]]) >> 3)
                try buffer.append(unwrap(table[str[offset + 6]]) << 5 | unwrap(table[str[offset + 7]]))
            }

            let offset = 8 * div
            var tmp = Data()
            switch mod {
            case 7:
                try tmp.append(unwrap(table[str[offset + 4]]) << 7 | unwrap(table[str[offset + 5]]) << 2 | unwrap(table[str[offset + 6]]) >> 3)
                fallthrough
            case 5:
                try tmp.append(unwrap(table[str[offset + 3]]) << 4 | unwrap(table[str[offset + 4]]) >> 1)
                fallthrough
            case 4:
                try tmp.append(unwrap(table[str[offset + 1]]) << 6 | unwrap(table[str[offset + 2]]) << 1 | unwrap(table[str[offset + 3]]) >> 4)
                fallthrough
            case 2:
                try tmp.append(unwrap(table[str[offset + 0]]) << 3 | unwrap(table[str[offset + 1]]) >> 2)
                buffer.append(contentsOf: tmp.reversed())
            default:
                break
            }
        } catch {
            fatalError()
        }

        self = buffer
    }

    /// Encode Crockford's Base32
    func base32EncodedString(using table: [Character] = Base32.crockfordsEncodingTable) -> String {
        let div = self.count / 5
        let mod = self.count % 5

        return self.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in
            var str = ""

            for i in 0 ..< div {
                let offset = 5 * i
                str.append(table[Int((bytes[offset + 0]               >> 3))])
                str.append(table[Int((bytes[offset + 0] & 0b00000111) << 2 | bytes[offset + 1] >> 6)])
                str.append(table[Int((bytes[offset + 1] & 0b00111110) >> 1)])
                str.append(table[Int((bytes[offset + 1] & 0b00000001) << 4 | bytes[offset + 2] >> 4)])
                str.append(table[Int((bytes[offset + 2] & 0b00001111) << 1 | bytes[offset + 3] >> 7)])
                str.append(table[Int((bytes[offset + 3] & 0b01111100) >> 2)])
                str.append(table[Int((bytes[offset + 3] & 0b00000011) << 3 | bytes[offset + 4] >> 5)])
                str.append(table[Int((bytes[offset + 4] & 0b00011111))])
            }

            let offset = 5 * div
            var tmp = ""
            var pad = 7
            switch mod {
            case 4:
                tmp.append(table[Int((bytes[offset + 3] & 0b00000011) << 3)])
                tmp.append(table[Int((bytes[offset + 3] & 0b01111100) >> 2)])
                pad -= 2
                fallthrough
            case 3:
                tmp.append(table[Int((bytes[offset + 2] & 0b00001111) << 1 | bytes[offset + 3] >> 7)])
                pad -= 1
                fallthrough
            case 2:
                tmp.append(table[Int((bytes[offset + 1] & 0b00000001) << 4 | bytes[offset + 2] >> 4)])
                tmp.append(table[Int((bytes[offset + 1] & 0b00111110) >> 1)])
                pad -= 2
                fallthrough
            case 1:
                tmp.append(table[Int((bytes[offset + 0] & 0b00000111) << 2 | bytes[offset + 1] >> 6)])
                tmp.append(table[Int((bytes[offset + 0]               >> 3))])
                pad -= 1
                str.append(contentsOf: tmp.reversed())
                str.append(String(repeating: "=", count: pad))
            default:
                break
            }

            return str
        }
    }

}
