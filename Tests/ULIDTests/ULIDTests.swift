//
//  ULIDTests.swift
//  ULIDTests
//
//  Created by Yasuhiro Hatta on 2019/01/11.
//  Copyright © 2019 yaslab. All rights reserved.
//

import XCTest
import ULID

final class ULIDTests: XCTestCase {

    func testGenerateTimestamp() {
        let expected: [UInt8] = [
            0x01, 0x68, 0x3D, 0x17, 0x73, 0x09, 0xE5
        ]

        let timestamp = Date(timeIntervalSince1970: 1547213173.513)
        let actual = ULID(timestamp: timestamp)

        XCTAssertEqual(expected[0], actual.ulid.0)
        XCTAssertEqual(expected[1], actual.ulid.1)
        XCTAssertEqual(expected[2], actual.ulid.2)
        XCTAssertEqual(expected[3], actual.ulid.3)
        XCTAssertEqual(expected[4], actual.ulid.4)
        XCTAssertEqual(expected[5], actual.ulid.5)

        XCTAssertEqual(timestamp, actual.timestamp)

        XCTAssertEqual(Array(expected.prefix(6)), Array(actual.ulidData.prefix(6)))

        XCTAssertEqual("01D0YHEWR9", actual.ulidString.prefix(10))
    }

    func testGenerateRandomness() {
        let timestamp = Date(timeIntervalSince1970: 1547213173.513)
        let ulid1 = ULID(timestamp: timestamp)
        let ulid2 = ULID(timestamp: timestamp)

        XCTAssertEqual(ulid1.timestamp, ulid2.timestamp)

        XCTAssertFalse(
            ulid1.ulid.6 == ulid2.ulid.6 &&
            ulid1.ulid.7 == ulid2.ulid.7 &&
            ulid1.ulid.8 == ulid2.ulid.8 &&
            ulid1.ulid.9 == ulid2.ulid.9 &&
            ulid1.ulid.10 == ulid2.ulid.10 &&
            ulid1.ulid.11 == ulid2.ulid.11 &&
            ulid1.ulid.12 == ulid2.ulid.12 &&
            ulid1.ulid.13 == ulid2.ulid.13 &&
            ulid1.ulid.14 == ulid2.ulid.14 &&
            ulid1.ulid.15 == ulid2.ulid.15
        )
    }

    func testParseULIDString() {
        let expected = "01D0YHEWR9WMPY4NNTPK1MR1TQ"

        let actual = ULID(ulidString: expected)

        XCTAssertNotNil(actual)
        XCTAssertEqual(expected, actual!.ulidString)
    }

    func testParseULIDData() {
        let expected: [UInt8] = [
            0x01, 0x68, 0x3D, 0x17, 0x73, 0x09, 0xE5, 0x2D,
            0xE2, 0x56, 0xBA, 0xB4, 0xC3, 0x4C, 0x07, 0x57
        ]

        let actual = ULID(ulidData: Data(bytes: expected))

        XCTAssertNotNil(actual)
        XCTAssertEqual(expected, Array(actual!.ulidData))
    }

    func testULIDDataLength() {
        let ulid = ULID()
        XCTAssertEqual(16, ulid.ulidData.count)
    }

    func testULIDStringLength() {
        let ulid = ULID()
        XCTAssertEqual(26, ulid.ulidString.count)
    }

    func testHashable1() {
        // Note: Hash values are not guaranteed to be equal across different executions.
        let ulid1 = ULID()
        let ulid2 = ULID(ulid: ulid1.ulid)
        XCTAssertEqual(ulid1.hashValue, ulid2.hashValue)
    }

    func testHashable2() {
        let timestamp = Date(timeIntervalSince1970: 1547213173.513)

        let ulid1 = ULID(timestamp: timestamp)
        let ulid2 = ULID(timestamp: timestamp)

        XCTAssertNotEqual(ulid1.hashValue, ulid2.hashValue)
    }

    func testHashable3() {
        let ulid1 = ULID()
        let ulid2 = ULID()
        let map = [ulid1: 1, ulid2: 2]

        XCTAssertEqual(1, map[ulid1]!)
        XCTAssertEqual(2, map[ulid2]!)
    }

    func testEquatable1() {
        let timestamp = Date(timeIntervalSince1970: 1547213173.513)

        let ulid1 = ULID(timestamp: timestamp)
        let ulid2 = ULID(ulid: ulid1.ulid)

        XCTAssertEqual(ulid1, ulid2)
    }

    func testEquatable2() {
        let timestamp = Date(timeIntervalSince1970: 1547213173.513)

        let ulid1 = ULID(timestamp: timestamp)
        let ulid2 = ULID(timestamp: timestamp)

        XCTAssertNotEqual(ulid1, ulid2)
    }

    func testComparable1() {
        let lhs = ULID(ulid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        let rhs = ULID(ulid: (0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        XCTAssertTrue(lhs < rhs)
        XCTAssertFalse(lhs > rhs)
    }

    func testComparable2() {
        let lhs = ULID(ulid: (0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        let rhs = ULID(ulid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        XCTAssertFalse(lhs < rhs)
        XCTAssertTrue(lhs > rhs)
    }

    func testComparable3() {
        let now = Date()
        let ulid0 = ULID(timestamp: now.addingTimeInterval(-120))
        let ulid1 = ULID(timestamp: now.addingTimeInterval(-60))
        let ulid2 = ULID(timestamp: now)
        let ulid3 = ULID(timestamp: now.addingTimeInterval(60))
        let ulid4 = ULID(timestamp: now.addingTimeInterval(120))
        let sorted = [ulid2, ulid0, ulid3, ulid4, ulid1].sorted()

        XCTAssertEqual(ulid0, sorted[0])
        XCTAssertEqual(ulid1, sorted[1])
        XCTAssertEqual(ulid2, sorted[2])
        XCTAssertEqual(ulid3, sorted[3])
        XCTAssertEqual(ulid4, sorted[4])
    }

    func testCustomStringConvertible() {
        let ulid = ULID()
        XCTAssertEqual(ulid.ulidString, ulid.description)
    }

    struct CodableModel: Codable {
        let ulid: ULID
    }

    func testDecodable() {
        let ulidString = "01D0YHEWR9WMPY4NNTPK1MR1TQ"
        let json = """
            { "ulid" : "\(ulidString)" }
            """
        do {
            let decoder = JSONDecoder()
            let model = try decoder.decode(CodableModel.self, from: json.data(using: .utf8)!)
            XCTAssertEqual(ulidString, model.ulid.ulidString)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testEncodable() {
        let ulidString = "01D0YHEWR9WMPY4NNTPK1MR1TQ"
        let expected = """
            {"ulid":"\(ulidString)"}
            """
        do {
            let encoder = JSONEncoder()
            let model = CodableModel(ulid: ULID(ulidString: ulidString)!)
            let actual = try String(data: encoder.encode(model), encoding: .utf8)
            XCTAssertEqual(expected, actual)
        } catch {
            XCTFail("\(error)")
        }
    }

    func testMemorySize() {
        XCTAssertEqual(16, MemoryLayout<ULID>.size)
    }

    static var allTests = [
        ("testGenerateTimestamp", testGenerateTimestamp),
        ("testGenerateRandomness", testGenerateRandomness),
        ("testParseULIDString", testParseULIDString),
        ("testParseULIDData", testParseULIDData),
        ("testULIDDataLength", testULIDDataLength),
        ("testULIDStringLength", testULIDStringLength),
        ("testHashable1", testHashable1),
        ("testHashable2", testHashable2),
        ("testHashable3", testHashable3),
        ("testEquatable1", testEquatable1),
        ("testEquatable2", testEquatable2),
        ("testComparable1", testComparable1),
        ("testComparable2", testComparable2),
        ("testComparable3", testComparable3),
        ("testCustomStringConvertible", testCustomStringConvertible),
        ("testDecodable", testDecodable),
        ("testEncodable", testEncodable),
        ("testMemorySize", testMemorySize)
    ]

}
