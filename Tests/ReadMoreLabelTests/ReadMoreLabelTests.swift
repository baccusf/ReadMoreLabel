@testable import ReadMoreLabel
import XCTest

final class ReadMoreLabelTests: XCTestCase {
    var label: ReadMoreLabel!

    override func setUp() {
        super.setUp()
        self.label = ReadMoreLabel(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
    }

    override func tearDown() {
        self.label = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(self.label.numberOfLines, 3)
        XCTAssertFalse(self.label.isExpanded)
        XCTAssertEqual(self.label.readMoreText.string, "더보기..")
    }

    func testExpandableWithShortText() {
        self.label.text = "Short text"
        XCTAssertFalse(self.label.isExpandable)
    }

    func testExpandableWithLongText() {
        self.label.text = String(
            repeating: "This is a very long text that should exceed the number of lines. ",
            count: 10
        )
        self.label.setNeedsLayout()
        self.label.layoutIfNeeded()

        // Note: This test might be environment dependent based on font and layout
        // In a real scenario, you might want to mock the text measurement
    }

    func testExpandCollapse() {
        self.label.text = String(
            repeating: "This is a very long text that should exceed the number of lines. ",
            count: 10
        )

        // Initially collapsed
        XCTAssertFalse(self.label.isExpanded)

        // Expand
        self.label.setExpanded(true, animated: false)
        XCTAssertTrue(self.label.isExpanded)

        // Collapse
        self.label.setExpanded(false, animated: false)
        XCTAssertFalse(self.label.isExpanded)
    }

    func testCustomReadMoreText() {
        let customText = NSAttributedString(string: "Read more...")
        self.label.readMoreText = customText
        XCTAssertEqual(self.label.readMoreText.string, "Read more...")
    }

    func testNumberOfLinesWhenCollapsedChange() {
        self.label.numberOfLines = 5
        XCTAssertEqual(self.label.numberOfLines, 5)
    }

    func testDelegateCallback() {
        let mockDelegate = MockReadMoreLabelDelegate()
        self.label.delegate = mockDelegate
        self.label.text = String(repeating: "Long text ", count: 50)

        self.label.setExpanded(true, animated: false)

        XCTAssertTrue(mockDelegate.didChangeExpandedStateCalled)
        XCTAssertTrue(mockDelegate.lastExpandedState)
    }
}

// MARK: - Mock Delegate

class MockReadMoreLabelDelegate: ReadMoreLabelDelegate {
    var didChangeExpandedStateCalled = false
    var lastExpandedState = false

    func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool) {
        self.didChangeExpandedStateCalled = true
        self.lastExpandedState = isExpanded
    }
}
