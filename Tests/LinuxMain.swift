import XCTest

import openGLTests

var tests = [XCTestCaseEntry]()
tests += openGLTests.allTests()
XCTMain(tests)
