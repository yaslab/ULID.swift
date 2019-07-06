//
//  Data+Base32Tests.swift
//  ULIDTests
//
//  Created by Yasuhiro Hatta on 2019/01/12.
//  Copyright © 2019 yaslab. All rights reserved.
//

import XCTest
@testable import ULID

final class Base32Tests: XCTestCase {

    // MARK: -
    // MARK: Encode

    func testEncodeBase32() {
        let expected = "00000001D0YX86C6ZTSZJNXFHDQMCYBQ"

        let bytes: [UInt8] = [
            0x00, 0x00, 0x00, 0x00, 0x01, 0x68, 0x3D, 0xD4, 0x19, 0x86,
            0xFE, 0xB3, 0xF9, 0x57, 0xAF, 0x8B, 0x6F, 0x46, 0x79, 0x77
        ]
        let data = Data(bytes)

        XCTAssertEqual(expected, data.base32EncodedString())
    }

    func testEncode1() {
        let bytes: [UInt8] = [
            0b11111000, 0b00000000, 0b00000000, 0b00000000, 0b00000000
        ]
        let data = Data(bytes)

        XCTAssertEqual("Z0000000", data.base32EncodedString())
    }

    func testEncode2() {
        let bytes: [UInt8] = [
            0b00000111, 0b11000000, 0b00000000, 0b00000000, 0b00000000
        ]
        let data = Data(bytes)

        XCTAssertEqual("0Z000000", data.base32EncodedString())
    }

    func testEncode3() {
        let bytes: [UInt8] = [
            0b00000000, 0b00111110, 0b00000000, 0b00000000, 0b00000000
        ]
        let data = Data(bytes)

        XCTAssertEqual("00Z00000", data.base32EncodedString())
    }

    func testEncode4() {
        let bytes: [UInt8] = [
            0b00000000, 0b00000001, 0b11110000, 0b00000000, 0b00000000
        ]
        let data = Data(bytes)

        XCTAssertEqual("000Z0000", data.base32EncodedString())
    }

    func testEncode5() {
        let bytes: [UInt8] = [
            0b00000000, 0b00000000, 0b00001111, 0b10000000, 0b00000000
        ]
        let data = Data(bytes)

        XCTAssertEqual("0000Z000", data.base32EncodedString())
    }

    func testEncode6() {
        let bytes: [UInt8] = [
            0b00000000, 0b00000000, 0b00000000, 0b01111100, 0b00000000
        ]
        let data = Data(bytes)

        XCTAssertEqual("00000Z00", data.base32EncodedString())
    }

    func testEncode7() {
        let bytes: [UInt8] = [
            0b00000000, 0b00000000, 0b00000000, 0b00000011, 0b11100000
        ]
        let data = Data(bytes)

        XCTAssertEqual("000000Z0", data.base32EncodedString())
    }

    func testEncode8() {
        let bytes: [UInt8] = [
            0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00011111
        ]
        let data = Data(bytes)

        XCTAssertEqual("0000000Z", data.base32EncodedString())
    }

    func testEncodePad1() {
        let bytes: [UInt8] = [
            0b10000100
        ]
        let data = Data(bytes)

        XCTAssertEqual("GG======", data.base32EncodedString())
    }

    func testEncodePad2() {
        let bytes: [UInt8] = [
            0b10000100, 0b00100001
        ]
        let data = Data(bytes)

        XCTAssertEqual("GGGG====", data.base32EncodedString())
    }

    func testEncodePad3() {
        let bytes: [UInt8] = [
            0b10000100, 0b00100001, 0b00001000
        ]
        let data = Data(bytes)

        XCTAssertEqual("GGGGG===", data.base32EncodedString())
    }

    func testEncodePad4() {
        let bytes: [UInt8] = [
            0b10000100, 0b00100001, 0b00001000, 0b01000010
        ]
        let data = Data(bytes)

        XCTAssertEqual("GGGGGGG=", data.base32EncodedString())
    }

    func testEncodeNoPad() {
        let bytes: [UInt8] = [
            0b10000100
        ]
        let data = Data(bytes)

        XCTAssertEqual("GG", data.base32EncodedString(padding: false))
    }

    // MARK: -
    // MARK: Decode

    func testDecodeBase32() {
        let expected: [UInt8] = [
            0x00, 0x00, 0x00, 0x00, 0x01, 0x68, 0x3D, 0xD4, 0x19, 0x86,
            0xFE, 0xB3, 0xF9, 0x57, 0xAF, 0x8B, 0x6F, 0x46, 0x79, 0x77
        ]

        let base32String = "00000001D0YX86C6ZTSZJNXFHDQMCYBQ"
        let data = Data(base32Encoded: base32String)

        XCTAssertNotNil(data)
        XCTAssertEqual(expected, Array(data!))
    }

    func testDecodeTable() {
        let table: [Character: UInt8] = [
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

        for (char, value) in table {
            let data = Data(base32Encoded: String(char) + "0")
            XCTAssertNotNil(data)
            XCTAssertEqual(1, data!.count)
            XCTAssertEqual(value << 3, data![0])
        }
    }

    func testDecodeInvalidCharacter() {
        let invalidCharacters = ["U", "u", "*", "~", "$", "="]

        for char in invalidCharacters {
            let data = Data(base32Encoded: char + "0")
            XCTAssertNil(data)
        }
    }

    func testDecodePadding() {
        let data = Data(base32Encoded: "AM======")
        XCTAssertNotNil(data)
        XCTAssertEqual(1, data!.count)
        XCTAssertEqual(0b01010101, data![0])
    }

    func testDecodeIncorrectLength() {
        let data = Data(base32Encoded: "0")
        XCTAssertNil(data)
    }

}
