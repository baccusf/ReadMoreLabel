import XCTest
@testable import ReadMoreLabel

/// ReadMoreLabel 핵심 기능 테스트 (Issue #3 요구사항 기반)
final class ReadMoreLabelTests: XCTestCase {
    
    // MARK: - Properties
    
    var label: ReadMoreLabel!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        label = ReadMoreLabel(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
    }
    
    override func tearDown() {
        label = nil
        super.tearDown()
    }
    
    // MARK: - 기본 초기화 및 설정 테스트
    
    func testBasicInitialization() {
        let newLabel = ReadMoreLabel()
        
        XCTAssertEqual(newLabel.numberOfLinesWhenCollapsed, 3, "기본 numberOfLinesWhenCollapsed는 3이어야 함")
        XCTAssertNotNil(newLabel.readMoreText, "기본 readMoreText가 설정되어야 함")
        XCTAssertEqual(newLabel.ellipsisText, "..", "기본 ellipsisText는 '..'이어야 함")
        XCTAssertEqual(newLabel.readMorePosition, .end, "기본 readMorePosition은 .end이어야 함")
        XCTAssertFalse(newLabel.isExpanded, "초기 상태는 collapsed이어야 함")
        XCTAssertEqual(newLabel.lineBreakMode, .byWordWrapping, "lineBreakMode는 .byWordWrapping으로 고정되어야 함")
    }
    
    func testInitialState() {
        XCTAssertEqual(label.numberOfLinesWhenCollapsed, 3)
        XCTAssertFalse(label.isExpanded)
        XCTAssertEqual(label.readMoreText?.string, "더보기..")
    }
    
    // MARK: - numberOfLinesWhenCollapsed = 0 테스트 (더보기 기능 비활성화)
    
    func testDisabledReadMoreFunctionality() {
        label.numberOfLinesWhenCollapsed = 0
        label.text = "This is a very long text that would normally be truncated but should not be truncated when numberOfLinesWhenCollapsed is set to 0."
        
        label.layoutIfNeeded()
        
        XCTAssertFalse(label.isExpandable, "numberOfLinesWhenCollapsed = 0일 때는 확장 불가능해야 함")
        XCTAssertFalse(label.isExpanded, "numberOfLinesWhenCollapsed = 0일 때는 항상 collapsed 상태")
    }
    
    // MARK: - 경계 조건 테스트 (TextKit 1 line counting 버그 수정 검증)
    
    func testBoundaryConditionExactLines() {
        label.numberOfLinesWhenCollapsed = 3
        label.font = UIFont.systemFont(ofSize: 16)
        
        // 정확히 3줄이 되는 텍스트 생성 (좁은 너비에서)
        let shortText = "Line one text here\nLine two text here\nLine three text here"
        label.text = shortText
        
        // 좁은 너비로 설정하여 3줄로 만들기
        label.frame = CGRect(x: 0, y: 0, width: 150, height: 1000)
        label.layoutIfNeeded()
        
        // >= 조건으로 인해 정확히 numberOfLines와 같을 때도 expandable해야 함
        XCTAssertTrue(label.isExpandable, "텍스트가 정확히 numberOfLinesWhenCollapsed와 같을 때도 확장 가능해야 함")
    }
    
    func testBoundaryConditionMoreThanLines() {
        label.numberOfLinesWhenCollapsed = 2
        label.font = UIFont.systemFont(ofSize: 16)
        
        // 2줄보다 많은 텍스트
        let longText = "This is a very long text that will definitely span more than two lines when rendered in a narrow container width to test boundary conditions properly."
        label.text = longText
        
        // 좁은 너비로 설정하여 강제로 여러 줄로 만들기
        label.frame = CGRect(x: 0, y: 0, width: 120, height: 1000)
        label.layoutIfNeeded()
        
        XCTAssertTrue(label.isExpandable, "텍스트가 numberOfLinesWhenCollapsed보다 많을 때 확장 가능해야 함")
    }
    
    func testExpandableWithShortText() {
        label.text = "Short text"
        label.layoutIfNeeded()
        XCTAssertFalse(label.isExpandable)
    }
    
    func testExpandableWithLongText() {
        label.text = String(repeating: "This is a very long text that should exceed the number of lines. ", count: 10)
        label.setNeedsLayout()
        label.layoutIfNeeded()
        
        XCTAssertTrue(label.isExpandable, "긴 텍스트는 확장 가능해야 함")
    }
    
    // MARK: - 확장/축소 기능 테스트
    
    func testExpandCollapse() {
        label.text = String(repeating: "This is a very long text that should exceed the number of lines. ", count: 10)
        label.layoutIfNeeded()
        
        // Initially collapsed
        XCTAssertFalse(label.isExpanded)
        
        // Expand
        label.setExpanded(true, animated: false)
        XCTAssertTrue(label.isExpanded)
        
        // Collapse
        label.setExpanded(false, animated: false)
        XCTAssertFalse(label.isExpanded)
    }
    
    func testExpandCollapseAnimated() {
        label.text = String(repeating: "This is a long text for testing animated expansion. ", count: 15)
        label.layoutIfNeeded()
        
        XCTAssertFalse(label.isExpanded, "초기 상태는 collapsed여야 함")
        
        // 애니메이션과 함께 확장
        label.setExpanded(true, animated: true)
        XCTAssertTrue(label.isExpanded, "setExpanded(true)로 확장되어야 함")
        
        // 애니메이션과 함께 축소
        label.setExpanded(false, animated: true)
        XCTAssertFalse(label.isExpanded, "setExpanded(false)로 축소되어야 함")
    }
    
    func testExpandCollapseConvenienceMethods() {
        label.text = String(repeating: "Text for testing expand/collapse convenience methods. ", count: 10)
        label.layoutIfNeeded()
        
        XCTAssertFalse(label.isExpanded, "초기 상태는 collapsed여야 함")
        
        // expand() 편의 메서드 테스트
        label.expand()
        XCTAssertTrue(label.isExpanded, "expand() 후에는 expanded 상태여야 함")
        
        // collapse() 편의 메서드 테스트
        label.collapse()
        XCTAssertFalse(label.isExpanded, "collapse() 후에는 collapsed 상태여야 함")
    }
    
    // MARK: - 커스터마이징 테스트
    
    func testCustomReadMoreText() {
        let customText = NSAttributedString(string: "Read more...")
        label.readMoreText = customText
        XCTAssertEqual(label.readMoreText?.string, "Read more...")
    }
    
    func testCustomReadMoreTextWithStyling() {
        let customReadMore = NSAttributedString(
            string: "자세히 보기 →",
            attributes: [
                .foregroundColor: UIColor.systemBlue,
                .font: UIFont.systemFont(ofSize: 14, weight: .medium)
            ]
        )
        label.readMoreText = customReadMore
        
        let longText = "This is a long text to test custom read more text functionality."
        label.text = longText
        
        label.frame = CGRect(x: 0, y: 0, width: 180, height: 1000)
        label.layoutIfNeeded()
        
        XCTAssertEqual(label.readMoreText?.string, "자세히 보기 →", "커스텀 readMoreText가 설정되어야 함")
        XCTAssertTrue(label.isExpandable, "긴 텍스트는 확장 가능해야 함")
    }
    
    func testCustomEllipsisText() {
        label.ellipsisText = "→"  // 화살표로 변경
        
        let longText = "This is a long text to test custom ellipsis text functionality."
        label.text = longText
        
        label.frame = CGRect(x: 0, y: 0, width: 180, height: 1000)
        label.layoutIfNeeded()
        
        XCTAssertEqual(label.ellipsisText, "→", "커스텀 ellipsisText가 설정되어야 함")
        XCTAssertTrue(label.isExpandable, "긴 텍스트는 확장 가능해야 함")
    }
    
    func testNumberOfLinesWhenCollapsedChange() {
        label.numberOfLinesWhenCollapsed = 5
        XCTAssertEqual(label.numberOfLinesWhenCollapsed, 5)
        
        // 변경 후 레이아웃 업데이트 확인
        let longText = String(repeating: "Test line change functionality. ", count: 20)
        label.text = longText
        label.layoutIfNeeded()
        
        // 5줄로 설정했으므로 확장 가능해야 함
        XCTAssertTrue(label.isExpandable, "numberOfLinesWhenCollapsed 변경 후 확장 가능해야 함")
    }
    
    // MARK: - Position 설정 테스트
    
    func testReadMorePositionEnd() {
        label.numberOfLinesWhenCollapsed = 2
        label.readMorePosition = .end
        label.font = UIFont.systemFont(ofSize: 16)
        
        let longText = "This is a long text for testing readMorePosition at the end of truncated content."
        label.text = longText
        
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 1000)
        label.layoutIfNeeded()
        
        XCTAssertEqual(label.readMorePosition, .end, "readMorePosition이 .end로 설정되어야 함")
        XCTAssertTrue(label.isExpandable, "긴 텍스트는 확장 가능해야 함")
    }
    
    func testReadMorePositionNewLine() {
        label.numberOfLinesWhenCollapsed = 2
        label.readMorePosition = .newLine
        label.font = UIFont.systemFont(ofSize: 16)
        
        let longText = "This is a long text for testing readMorePosition on a new line after truncated content."
        label.text = longText
        
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 1000)
        label.layoutIfNeeded()
        
        XCTAssertEqual(label.readMorePosition, .newLine, "readMorePosition이 .newLine으로 설정되어야 함")
        XCTAssertTrue(label.isExpandable, "긴 텍스트는 확장 가능해야 함")
    }
    
    // MARK: - NSAttributedString 지원 테스트
    
    func testAttributedStringSupport() {
        label.numberOfLinesWhenCollapsed = 2
        
        let attributedText = NSMutableAttributedString(string: "This is attributed text that should support different styles and formatting options.")
        attributedText.addAttribute(.foregroundColor, value: UIColor.blue, range: NSRange(location: 0, length: 4))
        attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 18), range: NSRange(location: 5, length: 2))
        
        label.attributedText = attributedText
        
        label.frame = CGRect(x: 0, y: 0, width: 180, height: 1000)
        label.layoutIfNeeded()
        
        XCTAssertNotNil(label.attributedText, "attributedText가 설정되어야 함")
        XCTAssertTrue(label.isExpandable, "긴 attributed text는 확장 가능해야 함")
    }
    
    // MARK: - 빈 텍스트 및 nil 텍스트 테스트
    
    func testEmptyAndNilText() {
        label.numberOfLinesWhenCollapsed = 3
        
        // 빈 텍스트 테스트
        label.text = ""
        label.layoutIfNeeded()
        XCTAssertFalse(label.isExpandable, "빈 텍스트는 확장 불가능해야 함")
        
        // nil 텍스트 테스트
        label.text = nil
        label.layoutIfNeeded()
        XCTAssertFalse(label.isExpandable, "nil 텍스트는 확장 불가능해야 함")
        
        // 공백만 있는 텍스트 테스트
        label.text = "   "
        label.layoutIfNeeded()
        XCTAssertFalse(label.isExpandable, "공백만 있는 텍스트는 확장 불가능해야 함")
    }
    
    // MARK: - 폰트 변경 테스트
    
    func testFontChanges() {
        label.numberOfLinesWhenCollapsed = 2
        
        let longText = "This is a long text to test how ReadMoreLabel handles font changes and layout updates."
        label.text = longText
        
        label.frame = CGRect(x: 0, y: 0, width: 180, height: 1000)
        
        // 초기 폰트로 레이아웃
        label.font = UIFont.systemFont(ofSize: 16)
        label.layoutIfNeeded()
        let isExpandableSmallFont = label.isExpandable
        
        // 더 큰 폰트로 변경
        label.font = UIFont.systemFont(ofSize: 24)
        label.layoutIfNeeded()
        let isExpandableLargeFont = label.isExpandable
        
        // 큰 폰트에서는 더 적은 텍스트라도 확장 가능할 수 있음
        XCTAssertTrue(isExpandableLargeFont, "큰 폰트에서는 확장 가능해야 함")
    }
    
    // MARK: - Delegate 테스트
    
    func testDelegateCallback() {
        let mockDelegate = MockReadMoreLabelDelegate()
        label.delegate = mockDelegate
        label.text = String(repeating: "Long text ", count: 50)
        label.layoutIfNeeded()
        
        label.setExpanded(true, animated: false)
        
        XCTAssertTrue(mockDelegate.didChangeExpandedStateCalled)
        XCTAssertTrue(mockDelegate.lastExpandedState)
        
        // 축소 테스트
        label.setExpanded(false, animated: false)
        XCTAssertFalse(mockDelegate.lastExpandedState)
    }
    
    func testDelegateCallbackOnlyOnChange() {
        let mockDelegate = MockReadMoreLabelDelegate()
        label.delegate = mockDelegate
        label.text = String(repeating: "Long text ", count: 50)
        label.layoutIfNeeded()
        
        // 처음 확장
        label.setExpanded(true, animated: false)
        XCTAssertEqual(mockDelegate.callCount, 1, "첫 번째 확장에서 델리게이트 호출")
        
        // 같은 상태로 다시 설정 (변경 없음)
        label.setExpanded(true, animated: false)
        XCTAssertEqual(mockDelegate.callCount, 1, "상태 변경이 없으면 델리게이트 호출 안 함")
    }
}

// MARK: - 회귀 방지 테스트

extension ReadMoreLabelTests {
    
    /// TextKit 1 line counting 경계 조건 버그 회귀 방지 테스트
    func testRegressionBoundaryConditionBug() {
        // 2025년 8월에 발견된 버그: 텍스트가 정확히 numberOfLinesWhenCollapsed와 같을 때 "더보기" 버튼이 미표시됨
        let label = ReadMoreLabel()
        label.numberOfLinesWhenCollapsed = 3
        label.font = UIFont.systemFont(ofSize: 16)
        
        // 정확히 3줄이 되는 시나리오 재현
        let exactThreeLinesText = "첫 번째 줄 텍스트\n두 번째 줄 텍스트\n세 번째 줄 텍스트"
        label.text = exactThreeLinesText
        
        // 좁은 너비로 설정하여 3줄로 만들기
        label.frame = CGRect(x: 0, y: 0, width: 150, height: 1000)
        label.layoutIfNeeded()
        
        // >= 조건으로 수정되어야 하므로 이제 expandable해야 함
        XCTAssertTrue(label.isExpandable, "회귀 방지: 텍스트가 정확히 numberOfLines와 같을 때도 확장 가능해야 함")
    }
    
    /// TextKit 변수 메모리 관리 버그 회귀 방지 테스트
    func testRegressionTextKitMemoryManagement() {
        // TextKit 스택 변수를 underscore로 변경했을 때 발생한 suffix 미표시 버그 회귀 방지
        let label = ReadMoreLabel()
        label.numberOfLinesWhenCollapsed = 2
        label.font = UIFont.systemFont(ofSize: 16)
        
        let longText = "이 텍스트는 TextKit 메모리 관리가 올바르게 작동하는지 확인하기 위한 긴 텍스트입니다. TextKit 스택 변수들이 제대로 유지되어야 합니다."
        label.text = longText
        
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 1000)
        label.layoutIfNeeded()
        
        // 메모리 관리가 제대로 되면 expandable해야 함
        XCTAssertTrue(label.isExpandable, "회귀 방지: TextKit 메모리 관리 문제로 인한 기능 실패 방지")
        
        // 확장 후에도 정상 작동해야 함
        label.expand()
        XCTAssertTrue(label.isExpanded, "회귀 방지: 확장 기능이 정상 작동해야 함")
        
        label.collapse()
        XCTAssertFalse(label.isExpanded, "회귀 방지: 축소 기능이 정상 작동해야 함")
    }
}

// MARK: - TextKit 메모리 관리 테스트

extension ReadMoreLabelTests {
    
    func testTextKitStackMemorySafety() {
        // TextKit 스택이 메모리에서 해제되지 않고 안전하게 관리되는지 테스트
        let label = ReadMoreLabel()
        label.numberOfLinesWhenCollapsed = 2
        
        let longTexts = [
            "First long text for memory safety testing with multiple layout cycles.",
            "Second different long text to test TextKit stack reuse and memory management.",
            "Third text with different length to verify consistent behavior across various inputs."
        ]
        
        for (index, text) in longTexts.enumerated() {
            label.text = text
            label.frame = CGRect(x: 0, y: 0, width: 180, height: 1000)
            label.layoutIfNeeded()
            
            // 각 텍스트 변경 후에도 정상 작동해야 함
            XCTAssertTrue(label.isExpandable, "텍스트 \(index + 1): TextKit 스택이 안전하게 관리되어야 함")
            
            // 확장/축소 기능 테스트
            label.expand()
            XCTAssertTrue(label.isExpanded, "텍스트 \(index + 1): 확장 기능이 정상 작동해야 함")
            
            label.collapse()
            XCTAssertFalse(label.isExpanded, "텍스트 \(index + 1): 축소 기능이 정상 작동해야 함")
        }
    }
    
    func testConcurrentTextKitOperations() {
        // 여러 ReadMoreLabel 인스턴스의 동시 텍스트 처리
        let labels = (0..<5).map { _ in ReadMoreLabel() }
        
        for (index, label) in labels.enumerated() {
            label.numberOfLinesWhenCollapsed = 2
            label.font = UIFont.systemFont(ofSize: 16)
            label.text = "Concurrent operation test text \(index) with additional content to ensure truncation."
            label.frame = CGRect(x: 0, y: 0, width: 180, height: 1000)
            label.layoutIfNeeded()
        }
        
        // 모든 라벨이 정상 작동해야 함
        for (index, label) in labels.enumerated() {
            XCTAssertTrue(label.isExpandable, "라벨 \(index): 동시 TextKit 작업에서 정상 작동해야 함")
            
            label.expand()
            XCTAssertTrue(label.isExpanded, "라벨 \(index): 동시 환경에서 확장 기능 정상 작동")
        }
    }
}

// MARK: - 다국어 및 특수문자 테스트

extension ReadMoreLabelTests {
    
    func testMultiLanguageSupport() {
        let testCases = [
            ("한국어", "안녕하세요! 이것은 한국어로 된 긴 텍스트입니다. ReadMoreLabel이 한국어 텍스트를 올바르게 처리하는지 확인하기 위한 테스트입니다."),
            ("日本語", "こんにちは！これは日本語で書かれた長いテキストです。ReadMoreLabelが日本語テキストを正しく処理できるかを確認するためのテストです。"),
            ("English", "Hello! This is a long text written in English. This test verifies that ReadMoreLabel correctly handles English text with proper word wrapping."),
            ("Español", "¡Hola! Este es un texto largo escrito en español. Esta prueba verifica que ReadMoreLabel maneje correctamente el texto en español."),
            ("Français", "Bonjour! Ceci est un long texte écrit en français. Ce test vérifie que ReadMoreLabel gère correctement le texte français.")
        ]
        
        for (language, text) in testCases {
            let label = ReadMoreLabel()
            label.numberOfLinesWhenCollapsed = 2
            label.font = UIFont.systemFont(ofSize: 16)
            label.text = text
            label.frame = CGRect(x: 0, y: 0, width: 200, height: 1000)
            label.layoutIfNeeded()
            
            XCTAssertTrue(label.isExpandable, "\(language): 다국어 텍스트가 확장 가능해야 함")
            
            // 확장/축소 테스트
            label.expand()
            XCTAssertTrue(label.isExpanded, "\(language): 확장 기능이 정상 작동해야 함")
            
            label.collapse()
            XCTAssertFalse(label.isExpanded, "\(language): 축소 기능이 정상 작동해야 함")
        }
    }
    
    func testEmojiAndSpecialCharacters() {
        let testCases = [
            "이모지 테스트: 🎉🎊🎈🎁🎂🍰🧁 파티 이모지들이 포함된 긴 텍스트입니다. 😊😋😍🥰😘",
            "복합 이모지: 👨‍👩‍👧‍👦👩‍💻🧑‍🎨👨‍🍳👩‍⚕️🧑‍🏫 직업 이모지들과 가족 이모지 테스트",
            "국기 이모지: 🇰🇷🇺🇸🇯🇵🇨🇳🇫🇷🇩🇪🇬🇧 다양한 국가의 국기 이모지 테스트입니다",
            "특수문자: ♠️♣️♥️♦️★☆♪♫♬ 기호와 음악 관련 특수문자들을 포함한 텍스트",
            "수학기호: ∑∏∫∂∇√∞≠≤≥±∓ 수학 기호들이 포함된 길고 복잡한 텍스트입니다"
        ]
        
        for (index, text) in testCases.enumerated() {
            let label = ReadMoreLabel()
            label.numberOfLinesWhenCollapsed = 2
            label.font = UIFont.systemFont(ofSize: 16)
            label.text = text
            label.frame = CGRect(x: 0, y: 0, width: 250, height: 1000)
            label.layoutIfNeeded()
            
            XCTAssertTrue(label.isExpandable, "특수문자 케이스 \(index + 1): 이모지/특수문자가 포함된 텍스트가 확장 가능해야 함")
            
            // 확장/축소 기능이 특수문자에도 정상 작동하는지 확인
            label.expand()
            XCTAssertTrue(label.isExpanded, "특수문자 케이스 \(index + 1): 확장 기능 정상 작동")
            
            label.collapse()
            XCTAssertFalse(label.isExpanded, "특수문자 케이스 \(index + 1): 축소 기능 정상 작동")
        }
    }
    
    func testMixedLanguageAndSpecialCharacters() {
        // 다국어와 특수문자가 혼합된 복합 케이스
        let mixedText = """
        🌏 다국어 테스트: Hello 안녕하세요 こんにちは Bonjour! 
        📱 This mixed content includes English, 한국어, 日本語, and français with emojis 🎉
        💻 It also contains numbers (123, 456) and special symbols: @#$%^&*()
        🎯 여러 언어가 섞인 긴 텍스트에서도 ReadMoreLabel이 정상 작동하는지 테스트합니다.
        """
        
        let label = ReadMoreLabel()
        label.numberOfLinesWhenCollapsed = 3
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = mixedText
        label.frame = CGRect(x: 0, y: 0, width: 280, height: 1000)
        label.layoutIfNeeded()
        
        XCTAssertTrue(label.isExpandable, "다국어+특수문자 혼합: 복합 텍스트가 확장 가능해야 함")
        
        // 확장 테스트
        label.expand()
        XCTAssertTrue(label.isExpanded, "다국어+특수문자 혼합: 확장 기능 정상 작동")
        
        // 축소 테스트
        label.collapse()
        XCTAssertFalse(label.isExpanded, "다국어+특수문자 혼합: 축소 기능 정상 작동")
    }
}

// MARK: - Mock Delegate

class MockReadMoreLabelDelegate: ReadMoreLabelDelegate {
    var didChangeExpandedStateCalled = false
    var lastExpandedState = false
    var callCount = 0
    
    func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool) {
        didChangeExpandedStateCalled = true
        lastExpandedState = isExpanded
        callCount += 1
    }
}