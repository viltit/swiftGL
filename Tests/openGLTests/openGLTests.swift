import XCTest
@testable import openGL

final class openGLTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(openGL().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
