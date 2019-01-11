import XCTest
import ULIDTests

var tests = [XCTestCaseEntry]()
tests += Base32Tests.allTests()
tests += ULIDTests.allTests()
XCTMain(tests)
