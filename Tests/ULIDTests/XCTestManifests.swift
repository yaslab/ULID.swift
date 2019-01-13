//
//  XCTestManifests.swift
//  ULIDTests
//
//  Created by Yasuhiro Hatta on 2019/01/11.
//  Copyright © 2019 yaslab. All rights reserved.
//

import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Base32Tests.allTests),
        testCase(ULIDTests.allTests)
    ]
}
#endif
