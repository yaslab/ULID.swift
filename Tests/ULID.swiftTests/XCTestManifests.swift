import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ULID_swiftTests.allTests),
    ]
}
#endif