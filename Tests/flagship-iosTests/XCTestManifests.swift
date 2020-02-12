import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(flagship_iosTests.allTests),
    ]
}
#endif
