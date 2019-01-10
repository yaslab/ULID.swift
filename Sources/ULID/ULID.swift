//
//  ULID.swift
//  ULID
//
//  Created by Yasuhiro Hatta on 2019/01/11.
//

import Foundation

public struct ULID {

    public let ulidString: String

    public init(timestamp: Date = Date()) {
        let now = UInt64(timestamp.timeIntervalSince1970 * 1000.0)
        let timestampBase32 = withUnsafePointer(to: now.bigEndian) { (pointer) -> String in
            var data = Data(bytes: pointer, count: 8)
            data.insert(contentsOf: [0x00, 0x00], at: 0)
            return String(data.base32EncodedString().suffix(10))
        }
        let randomness = (0 ..< 16).map { _ in
            Base32.crockfordsEncodingTable[Int.random(in: 0 ..< Base32.crockfordsEncodingTable.count)]
        }
        self.ulidString = timestampBase32 + String(randomness)
    }

    public init(ulidString string: String) {
        self.ulidString = string
    }

}

extension ULID {

    private func decodeTimestamp() -> Date? {
        let base32 = "000000" + String(self.ulidString.prefix(10))
        guard let data = Data(base32Encoded: base32) else {
            return nil
        }
        return data.suffix(8).withUnsafeBytes { (pointer: UnsafePointer<UInt64>) in
            Date(timeIntervalSince1970: TimeInterval(pointer.pointee.bigEndian) / 1000.0)
        }
    }

    public var timestamp: Date {
        // TODO: Validate on `init`
        return self.decodeTimestamp()!
    }

}
