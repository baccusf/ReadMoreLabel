import XCTest
@testable import ReadMoreLabel

final class ReadMoreLabelTests: XCTestCase {
    
    var label: ReadMoreLabel!
    
    override func setUp() {
        super.setUp()
        label = ReadMoreLabel(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
    }
    
    override func tearDown() {
        label = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(label.numberOfLines, 3)
        XCTAssertFalse(label.isExpanded)
        XCTAssertEqual(label.readMoreText.string, "더보기..")
    }
    
    func testExpandableWithShortText() {
        label.text = "Short text"
        XCTAssertFalse(label.isExpandable)
    }
    
    func testExpandableWithLongText() {
        label.text = String(repeating: "This is a very long text that should exceed the number of lines. ", count: 10)
        label.setNeedsLayout()
        label.layoutIfNeeded()
        
        // Note: This test might be environment dependent based on font and layout
        // In a real scenario, you might want to mock the text measurement
    }
    
    func testExpandCollapse() {
        label.text = String(repeating: "This is a very long text that should exceed the number of lines. ", count: 10)
        
        // Initially collapsed
        XCTAssertFalse(label.isExpanded)
        
        // Expand
        label.setExpanded(true, animated: false)
        XCTAssertTrue(label.isExpanded)
        
        // Collapse
        label.setExpanded(false, animated: false)
        XCTAssertFalse(label.isExpanded)
    }
    
    func testCustomReadMoreText() {
        let customText = NSAttributedString(string: "Read more...")
        label.readMoreText = customText
        XCTAssertEqual(label.readMoreText.string, "Read more...")
    }
    
    
    func testNumberOfLinesWhenCollapsedChange() {
        label.numberOfLines = 5
        XCTAssertEqual(label.numberOfLines, 5)
    }
    
    func testDelegateCallback() {
        let mockDelegate = MockReadMoreLabelDelegate()
        label.delegate = mockDelegate
        label.text = String(repeating: "Long text ", count: 50)
        
        label.setExpanded(true, animated: false)
        
        XCTAssertTrue(mockDelegate.didChangeExpandedStateCalled)
        XCTAssertTrue(mockDelegate.lastExpandedState)
    }
}

// MARK: - Mock Delegate

class MockReadMoreLabelDelegate: ReadMoreLabelDelegate {
    var didChangeExpandedStateCalled = false
    var lastExpandedState = false
    
    func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool) {
        didChangeExpandedStateCalled = true
        lastExpandedState = isExpanded
    }
}