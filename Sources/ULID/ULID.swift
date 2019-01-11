//
//  ULID.swift
//  ULID
//
//  Created by Yasuhiro Hatta on 2019/01/11.
//

import Foundation

public typealias ulid_t = uuid_t

public struct ULID {

    public private(set) var ulid: ulid_t = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

    public init(ulid: ulid_t) {
        self.ulid = ulid
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

}
