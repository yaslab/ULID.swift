//
//  ULIDTests.swift
//  ULIDTests
//
//  Created by Yasuhiro Hatta on 2019/01/11.
//  Copyright © 2019 yaslab. All rights reserved.
//

#if compiler(>=6.0)

import Foundation
import Testing
import ULID

struct ULIDTests {

    @Test func testGenerateTimestamp() {
        let expected: [UInt8] = [
            0x01, 0x68, 0x3D, 0x17, 0x73, 0x09, 0xE5
        ]

        let timestamp = Date(timeIntervalSince1970: 1547213173.513)
        let actual = ULID(timestamp: timestamp)

        #expect(expected[0] == actual.ulid.0)
        #expect(expected[1] == actual.ulid.1)
        #expect(expected[2] == actual.ulid.2)
        #expect(expected[3] == actual.ulid.3)
        #expect(expected[4] == actual.ulid.4)
        #expect(expected[5] == actual.ulid.5)

        #expect(timestamp == actual.timestamp)

        #expect(Array(expected.prefix(6)) == Array(actual.ulidData.prefix(6)))

        #expect("01D0YHEWR9" == actual.ulidString.prefix(10))
    }
    
    @Test func testGenerateTimestampAndRandomnes() throws {
        let timestamp = Date(timeIntervalSince1970: 1547213173.513)
        let uuidCorrectSize: [UInt8] = [
            0x01, 0x68, 0x3D, 0x17, 0x73, 0x09, 0x69, 0xF4, 0xA2, 0xB1
        ]
        
        let actual = try #require(ULID(timestamp: timestamp, randomPartData: Data(uuidCorrectSize)))

        #expect(timestamp == actual.timestamp)
        
        #expect(0x01 == actual.ulid.6)
        #expect(0x68 == actual.ulid.7)
        #expect(0x3D == actual.ulid.8)
        #expect(0x17 == actual.ulid.9)
        #expect(0x73 == actual.ulid.10)
        #expect(0x09 == actual.ulid.11)
        #expect(0x69 == actual.ulid.12)
        #expect(0xF4 == actual.ulid.13)
        #expect(0xA2 == actual.ulid.14)
        #expect(0xB1 == actual.ulid.15)
    }

    @Test func testGenerateTimestampAndRandomnes2() throws {
        let timestamp = Date(timeIntervalSince1970: 1547213173.513)
        // Test if initializer discards bytes beyond 10 bytes
        let uuidTooBigSize: [UInt8] = [
            0x01, 0x68, 0x3D, 0x17, 0x73, 0x09, 0x69, 0xF4, 0xA2, 0xB1, 0x99, 0x55
        ]
        
        let actual = try #require(ULID(timestamp: timestamp, randomPartData: Data(uuidTooBigSize)))

        #expect(timestamp == actual.timestamp)
        
        #expect(0x01 == actual.ulid.6)
        #expect(0x68 == actual.ulid.7)
        #expect(0x3D == actual.ulid.8)
        #expect(0x17 == actual.ulid.9)
        #expect(0x73 == actual.ulid.10)
        #expect(0x09 == actual.ulid.11)
        #expect(0x69 == actual.ulid.12)
        #expect(0xF4 == actual.ulid.13)
        #expect(0xA2 == actual.ulid.14)
        #expect(0xB1 == actual.ulid.15)
    }

    @Test func testGenerateTimestampAndRandomnes3() {
        let timestamp = Date(timeIntervalSince1970: 1547213173.513)
        let uuidTooSmallSize: [UInt8] = [
            0x01, 0x68, 0x3D, 0x17, 0x73,
        ]
        
        let actual = ULID(timestamp: timestamp, randomPartData: Data(uuidTooSmallSize))

        #expect(actual == nil)
    }

    @Test func testGenerateRandomness() {
        let timestamp = Date(timeIntervalSince1970: 1547213173.513)
        var generator = RandomNumberGeneratorStub(value: 0x1122334455667788)
        let actual = ULID(timestamp: timestamp, generator: &generator)

        #expect(timestamp == actual.timestamp)

        #expect(0x77 == actual.ulid.6)
        #expect(0x88 == actual.ulid.7)
        #expect(0x11 == actual.ulid.8)
        #expect(0x22 == actual.ulid.9)
        #expect(0x33 == actual.ulid.10)
        #expect(0x44 == actual.ulid.11)
        #expect(0x55 == actual.ulid.12)
        #expect(0x66 == actual.ulid.13)
        #expect(0x77 == actual.ulid.14)
        #expect(0x88 == actual.ulid.15)
    }

    @Test func testParseULIDString() throws {
        let expected = "01D0YHEWR9WMPY4NNTPK1MR1TQ"

        let actual = try #require(ULID(ulidString: expected))

        #expect(expected == actual.ulidString)
    }

    @Test func testParseULIDStringError() {
        let zero = ""

        let actual = ULID(ulidString: zero)

        #expect(actual == nil)
    }

    @Test func testParseULIDData() throws {
        let expected: [UInt8] = [
            0x01, 0x68, 0x3D, 0x17, 0x73, 0x09, 0xE5, 0x2D,
            0xE2, 0x56, 0xBA, 0xB4, 0xC3, 0x4C, 0x07, 0x57
        ]

        let actual = try #require(ULID(ulidData: Data(expected)))

        #expect(expected == Array(actual.ulidData))
    }

    @Test func testParseULIDDataError() {
        let zero = Data()

        let actual = ULID(ulidData: zero)

        #expect(actual == nil)
    }

    @Test func testULIDDataLength() {
        let ulid = ULID()
        #expect(16 == ulid.ulidData.count)
    }

    @Test func testULIDStringLength() {
        let ulid = ULID()
        #expect(26 == ulid.ulidString.count)
    }

    @Test func testHashable1() {
        // Note: Hash values are not guaranteed to be equal across different executions.
        let ulid1 = ULID()
        let ulid2 = ULID(ulid: ulid1.ulid)
        #expect(ulid1.hashValue == ulid2.hashValue)
    }

    @Test func testHashable2() {
        let timestamp = Date(timeIntervalSince1970: 1547213173.513)

        let ulid1 = ULID(timestamp: timestamp)
        let ulid2 = ULID(timestamp: timestamp)

        #expect(ulid1.hashValue != ulid2.hashValue)
    }

    @Test func testHashable3() {
        let ulid1 = ULID()
        let ulid2 = ULID()
        let map = [ulid1: 1, ulid2: 2]

        #expect(map[ulid1] == 1)
        #expect(map[ulid2] == 2)
    }

    @Test func testEquatable1() {
        let timestamp = Date(timeIntervalSince1970: 1547213173.513)

        let ulid1 = ULID(timestamp: timestamp)
        let ulid2 = ULID(ulid: ulid1.ulid)

        #expect(ulid1 == ulid2)
    }

    @Test func testEquatable2() {
        let timestamp = Date(timeIntervalSince1970: 1547213173.513)

        let ulid1 = ULID(timestamp: timestamp)
        let ulid2 = ULID(timestamp: timestamp)

        #expect(ulid1 != ulid2)
    }

    @Test func testComparable1() {
        let lhs = ULID(ulid: (1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        let rhs = ULID(ulid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        #expect((lhs < rhs) == false)
        #expect((lhs > rhs) == true)
    }

    @Test func testComparable2() {
        let lhs = ULID(ulid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1))
        let rhs = ULID(ulid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        #expect((lhs < rhs) == false)
        #expect((lhs > rhs) == true)
    }

    @Test func testComparable3() {
        let lhs = ULID(ulid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        let rhs = ULID(ulid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1))
        #expect((lhs < rhs) == true)
        #expect((lhs > rhs) == false)
    }

    @Test func testComparable4() {
        let now = Date()
        let ulid0 = ULID(timestamp: now.addingTimeInterval(-120))
        let ulid1 = ULID(timestamp: now.addingTimeInterval(-60))
        let ulid2 = ULID(timestamp: now)
        let ulid3 = ULID(timestamp: now.addingTimeInterval(60))
        let ulid4 = ULID(timestamp: now.addingTimeInterval(120))
        let sorted = [ulid2, ulid0, ulid3, ulid4, ulid1].sorted()

        #expect(ulid0 == sorted[0])
        #expect(ulid1 == sorted[1])
        #expect(ulid2 == sorted[2])
        #expect(ulid3 == sorted[3])
        #expect(ulid4 == sorted[4])
    }

    @Test func testCustomStringConvertible() {
        let ulid = ULID()
        #expect(ulid.ulidString == ulid.description)
    }

    struct CodableModel: Codable {
        let ulid: ULID
    }

    @Test func testDecodable() throws {
        let ulidString = "01D0YHEWR9WMPY4NNTPK1MR1TQ"
        let json = """
            { "ulid" : "\(ulidString)" }
            """
        let data = try #require(json.data(using: .utf8))
        let decoder = JSONDecoder()

        let model = try decoder.decode(CodableModel.self, from: data)

        #expect(ulidString == model.ulid.ulidString)
    }

    @Test func testDecodableError() throws {
        let json = """
            { "ulid" : "" }
            """
        let data = try #require(json.data(using: .utf8))
        let decoder = JSONDecoder()

        #expect {
            try decoder.decode(CodableModel.self, from: data)
        } throws: {
            guard let error = $0 as? DecodingError else {
                return false
            }
            guard case .dataCorrupted = error else {
                return false
            }
            return true
        }
    }

    @Test func testEncodable() throws {
        let ulidString = "01D0YHEWR9WMPY4NNTPK1MR1TQ"
        let expected = """
            {"ulid":"\(ulidString)"}
            """
        let model = try CodableModel(
            ulid: #require(ULID(ulidString: ulidString))
        )
        let encoder = JSONEncoder()

        let data = try encoder.encode(model)

        let actual = try #require(String(data: data, encoding: .utf8))
        #expect(expected == actual)
    }

    @Test func testMemorySize() {
        #expect(MemoryLayout<ULID>.size == 16)
    }

    @Test func testMonotonicFactory() {
        let factory = ULID.MonotonicFactory()
        let timestamp = Date()
        
        // Test multiple increments in same millisecond
        let ulid1 = factory.create(timestamp: timestamp)
        let ulid2 = factory.create(timestamp: timestamp)
        let ulid3 = factory.create(timestamp: timestamp)
        let ulid4 = factory.create(timestamp: timestamp)
        let ulid5 = factory.create(timestamp: timestamp)
        
        // Verify all are strictly increasing
        #expect(ulid1 < ulid2)
        #expect(ulid2 < ulid3)
        #expect(ulid3 < ulid4)
        #expect(ulid4 < ulid5)
        
        // Verify they all have the same timestamp component
        let timeComponent: String = String(ulid1.ulidString.prefix(10))
        #expect(timeComponent == String(ulid2.ulidString.prefix(10)))
        #expect(timeComponent == String(ulid3.ulidString.prefix(10)))
        #expect(timeComponent == String(ulid4.ulidString.prefix(10)))
        #expect(timeComponent == String(ulid5.ulidString.prefix(10)))
        
        // Test with future timestamp after sequence
        let newerTimestamp: Date = timestamp.addingTimeInterval(1)
        let ulid6 = factory.create(timestamp: newerTimestamp)
        
        #expect(ulid5 < ulid6)
        #expect(String(ulid5.ulidString.prefix(10)) != String(ulid6.ulidString.prefix(10)))
    }

    
}

extension ULID {
    // If the ULID does not conform to Sendable, this code will result in a build error in Swift 6 mode.
    static let testSendable = ULID()
}

private struct RandomNumberGeneratorStub: RandomNumberGenerator {

    let value: UInt64

    mutating func next() -> UInt64 {
        return value
    }

}

#endif
