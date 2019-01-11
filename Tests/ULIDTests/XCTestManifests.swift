import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Base32Tests.allTests),
        testCase(ULIDTests.allTests)
    ]
}
#endif
