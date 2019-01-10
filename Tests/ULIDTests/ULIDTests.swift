//
//  ULIDTests.swift
//  ULIDTests
//
//  Created by Yasuhiro Hatta on 2019/01/11.
//

import XCTest
import ULID

final class ULIDTests: XCTestCase {

    func testExample() {
        let ulid = ULID()
        XCTAssertEqual(ulid.ulidString.count, 26)
    }

    static var allTests = [
        ("testExample", testExample)
    ]

}
