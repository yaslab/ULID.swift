//
//  Data+Base32Tests.swift
//  ULIDTests
//
//  Created by Yasuhiro Hatta on 2019/01/12.
//

import XCTest
@testable import ULID

final class Base32Tests: XCTestCase {

    func testEncodeBase32() {
        let expected = "00000001D0YX86C6ZTSZJNXFHDQMCYBQ"

        let bytes: [UInt8] = [
            0x00, 0x00, 0x00, 0x00, 0x01, 0x68, 0x3D, 0xD4, 0x19, 0x86,
            0xFE, 0xB3, 0xF9, 0x57, 0xAF, 0x8B, 0x6F, 0x46, 0x79, 0x77
        ]
        let data = Data(bytes: bytes)

        XCTAssertEqual(expected, data.base32EncodedString())
    }

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

    static var allTests = [
        ("testEncodeBase32", testEncodeBase32),
        ("testDecodeBase32", testDecodeBase32)
    ]

}
