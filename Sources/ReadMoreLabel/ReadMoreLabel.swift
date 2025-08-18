import UIKit

@available(iOS 16.0, *)
@objc public protocol ReadMoreLabelDelegate: AnyObject {
    @objc optional func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool)
}

/// UILabel with "Read More" functionality for truncated text
@available(iOS 16.0, *)
@objc @IBDesignable
public class ReadMoreLabel: UILabel {
    
    @objc public enum Position: Int {
        case end = 0
        case newLine = 1
    }
    
    // MARK: - Custom Attributed String Keys
    
    /// ReadMoreLabel 전용 커스텀 속성 키
    public struct AttributeKey {
        /// "더보기" 텍스트를 식별하는 속성 키
        public static let isReadMore = NSAttributedString.Key("ReadMoreLabel.isReadMore")
    }
    
    // MARK: - Public Properties
    
    @objc public weak var delegate: ReadMoreLabelDelegate?
    
    private var numberOfLinesWhenCollapsed: Int = 3 {
        didSet {
            let finalValue = max(0, numberOfLinesWhenCollapsed)
            if finalValue != numberOfLinesWhenCollapsed {
                numberOfLinesWhenCollapsed = finalValue
                return
            }
            invalidateDisplayAndLayout()
        }
    }
    
    @objc public var readMoreText: NSAttributedString = NSAttributedString(string: "더보기..") {
        didSet {
            invalidateDisplayAndLayout()
        }
    }
    
    @IBInspectable public var ellipsisText: String = ".." {
        didSet {
            invalidateDisplayAndLayout()
        }
    }
    
    @objc public var readMorePosition: Position = .end {
        didSet {
            invalidateDisplayAndLayout()
        }
    }
    @objc public private(set) var isExpanded: Bool = false
    
    @objc public var isExpandable: Bool {
        guard numberOfLinesWhenCollapsed > 0,
              let readMoreTextRange = readMoreTextRange else {
            return false
        }
        return readMoreTextRange.length > 0
    }
    
    // MARK: - Private Properties
    
    private var readMoreTextRange: NSRange?
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var originalAttributedText: NSAttributedString?
    private var internalNumberOfLines: Int = 0
    
    // 캐시 시스템
    private var cachedIsExpandable: Bool?
    private var cachedExpandableKey: String?
    private var lastLayoutBounds: CGRect = .zero
    
    // TextKit 재사용을 위한 캐시
    private var reusableTextLayoutManager: NSTextLayoutManager?
    private var reusableTextContainer: NSTextContainer?
    private var reusableTextContentStorage: NSTextContentStorage?
    
    // 상수 정의
    private static let defaultFallbackWidth: CGFloat = 300.0
    private static let animationDuration: TimeInterval = 0.3
       
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabel()
    }
    
    // MARK: - Setup
    
    private func setupLabel() {
        setInternalNumberOfLines(numberOfLinesWhenCollapsed == 0 ? 0 : numberOfLinesWhenCollapsed)
        lineBreakMode = .byClipping
        isUserInteractionEnabled = true
        setupTapGesture()
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGestureRecognizer = tapGesture
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Public Methods
    
    @objc public func expand() {
        setExpanded(true, animated: true)
    }
    
    @objc public func collapse() {
        setExpanded(false, animated: true)
    }
    
    @objc public func setExpanded(_ expanded: Bool, animated: Bool) {
        // 확장하려는 경우 isExpandable 체크, 축소하려는 경우는 항상 허용
        guard expanded == false || isExpandable else { return }
        
        // 같은 상태로 변경하려는 경우 early return
        guard expanded != isExpanded else { return }
        
        isExpanded = expanded
        updateDisplay()
        
        if animated {
            UIView.animate(withDuration: Self.animationDuration) {
                self.invalidateIntrinsicContentSize()
            }
        } else {
            invalidateDisplayAndLayout()
        }
        
        delegate?.readMoreLabel?(self, didChangeExpandedState: isExpanded)
    }
    
    @objc public func prepareForCellReuse() {
        invalidateExpandableCache()
        if isExpanded {
            setExpanded(false, animated: false)
        }
    }
    
    // MARK: - Custom Attribute Utilities
    
    /// 현재 표시된 텍스트에서 "더보기" 텍스트의 범위를 커스텀 속성으로 찾기
    /// - Returns: "더보기" 텍스트의 범위들 (여러 개일 수 있음)
    @objc public func findReadMoreTextRanges() -> [NSRange] {
        guard let attributedText = attributedText else {
            return []
        }
        
        var ranges: [NSRange] = []
        let fullRange = NSRange(location: 0, length: attributedText.length)
        
        attributedText.enumerateAttribute(
            AttributeKey.isReadMore,
            in: fullRange,
            options: []
        ) { value, range, _ in
            if let isReadMore = value as? Bool, isReadMore {
                ranges.append(range)
            }
        }
        
        return ranges
    }
    
    // MARK: - TextKit 2 Implementation
    
    /// 텍스트 자르기 결과 열거형
    private enum TextTruncationResult {
        case noTruncationNeeded
        case truncated(NSAttributedString, NSRange)
        
        /// 자르기가 필요한지 여부
        var needsTruncation: Bool {
            switch self {
            case .noTruncationNeeded:
                return false
            case .truncated:
                return true
            }
        }
        
        /// 최종 텍스트와 더보기 범위 추출
        var textAndRange: (NSAttributedString, NSRange?)? {
            switch self {
            case .noTruncationNeeded:
                return nil
            case .truncated(let text, let range):
                return (text, range)
            }
        }
    }
    private func applyReadMoreWithTextKit2(
        originalText: NSAttributedString,
        numberOfLines: Int,
        containerWidth: CGFloat,
        suffix: NSAttributedString
    ) -> TextTruncationResult {
        
        let suffixWidth = measureSuffixWidth(suffix: suffix)
        let alignedText = applyTextAlignment(to: originalText)
        let (textLayoutManager, lineAnalysis) = setupTextKitAndAnalyzeLines(
            alignedText: alignedText,
            containerWidth: containerWidth,
            targetLineCount: numberOfLines
        )
        
        guard lineAnalysis.totalLineCount >= numberOfLines,
              let targetFragment = lineAnalysis.targetFragment else {
            return .noTruncationNeeded
        }
        
        let truncateLocation = calculateTruncateLocation(
            targetFragment: targetFragment,
            containerWidth: containerWidth,
            suffixWidth: suffixWidth,
            textLayoutManager: textLayoutManager,
            alignedText: alignedText
        )
        
        guard let truncateLoc = truncateLocation else {
            return .noTruncationNeeded
        }
        
        let truncateOffset = textLayoutManager.offset(from: textLayoutManager.documentRange.location, to: truncateLoc)
        let truncatedText = originalText.attributedSubstring(from: NSRange(location: 0, length: truncateOffset))
        
        let cleanedTruncatedText = removeTrailingNewlineIfNeeded(from: truncatedText)
        
        let finalText = NSMutableAttributedString(attributedString: cleanedTruncatedText)
        finalText.append(suffix)
        
        let readMoreRange = NSRange(location: cleanedTruncatedText.length, length: suffix.length)
        
        return .truncated(finalText, readMoreRange)
    }
    
    private func findOptimalTruncateLocationInline(
        in range: NSTextRange,
        availableWidth: CGFloat,
        textLayoutManager: NSTextLayoutManager
    ) -> NSTextLocation {
        
        let rangeStartOffset = textLayoutManager.offset(from: textLayoutManager.documentRange.location, to: range.location)
        let rangeEndOffset = textLayoutManager.offset(from: textLayoutManager.documentRange.location, to: range.endLocation)
        
        let fullLineWidth = measureTextWidth(in: range, textLayoutManager: textLayoutManager)
        
        if fullLineWidth <= availableWidth {
            return range.endLocation
        }
        
        let totalLength = rangeEndOffset - rangeStartOffset
        for truncateLength in (1...totalLength).reversed() {
            guard let truncateLocation = textLayoutManager.location(range.location, offsetBy: truncateLength) else {
                continue
            }
            
            guard let testRange = NSTextRange(location: range.location, end: truncateLocation) else {
                continue
            }
            
            let testWidth = measureTextWidth(in: testRange, textLayoutManager: textLayoutManager)
            
            if testWidth <= availableWidth {
                return truncateLocation
            }
        }
        
        return textLayoutManager.location(range.location, offsetBy: 1) ?? range.location
    }
    
    private func measureTextWidth(in range: NSTextRange, textLayoutManager: NSTextLayoutManager) -> CGFloat {
        var totalWidth: CGFloat = 0
        
        textLayoutManager.enumerateTextSegments(in: range, type: .standard, options: []) { 
            segmentRange, segmentFrame, baselineOffset, textContainer in
            totalWidth += segmentFrame.width
            return true
        }
        
        return totalWidth
    }
    
    private func createReadMoreSuffix(from originalText: NSAttributedString) -> NSAttributedString {
        let lastAttributes = getLastTextAttributes(from: originalText)
        
        let suffix = NSMutableAttributedString()
        
        // 줄임표 추가 (원본 텍스트 속성 사용)
        suffix.append(NSAttributedString(string: ellipsisText, attributes: lastAttributes))
        suffix.append(NSAttributedString(string: " ", attributes: lastAttributes))
        
        // "더보기" 텍스트 추가 (기존 속성 사용)
        suffix.append(readMoreText)
        
        // "더보기" 텍스트 부분만 찾아서 커스텀 속성 추가
        let readMoreStartLocation = suffix.length - readMoreText.length
        let readMoreRange = NSRange(location: readMoreStartLocation, length: readMoreText.length)
        
        // "더보기" 부분에만 커스텀 속성 추가
        suffix.addAttribute(AttributeKey.isReadMore, value: true, range: readMoreRange)
        
        return suffix
    }
    
    
    /// TextKit 설정 및 라인 분석을 수행하는 공통 헬퍼 메서드
    /// - Parameters:
    ///   - alignedText: 정렬이 적용된 속성 문자열
    ///   - containerWidth: 컨테이너 너비
    ///   - targetLineCount: 대상 라인 수
    /// - Returns: TextLayoutManager와 라인 분석 결과
    private func setupTextKitAndAnalyzeLines(
        alignedText: NSAttributedString,
        containerWidth: CGFloat,
        targetLineCount: Int
    ) -> (NSTextLayoutManager, LineAnalysisResult) {
        
        let (textLayoutManager, _, _) = getReusableTextKit(
            containerWidth: containerWidth,
            attributedText: alignedText
        )
        
        textLayoutManager.ensureLayout(for: textLayoutManager.documentRange)
        
        let lineAnalysis = analyzeTextLines(
            textLayoutManager: textLayoutManager,
            targetLineCount: targetLineCount
        )
        
        return (textLayoutManager, lineAnalysis)
    }
    
    /// 마지막 줄바꿈 문자를 제거하는 공통 헬퍼 메서드
    /// - Parameter attributedString: 처리할 속성 문자열
    /// - Returns: 줄바꿈이 제거된 속성 문자열
    private func removeTrailingNewlineIfNeeded(from attributedString: NSAttributedString) -> NSAttributedString {
        let mutableString = NSMutableAttributedString(attributedString: attributedString)
        if mutableString.string.hasSuffix("\n") {
            let newLength = mutableString.length - 1
            mutableString.deleteCharacters(in: NSRange(location: newLength, length: 1))
        }
        return mutableString
    }
    
    /// 마지막 텍스트 속성을 추출하는 공통 헬퍼 메서드
    /// - Parameter originalText: 원본 속성 문자열
    /// - Returns: 마지막 문자의 속성 또는 기본 속성
    private func getLastTextAttributes(from originalText: NSAttributedString) -> [NSAttributedString.Key: Any] {
        return originalText.length > 0 ?
            originalText.attributes(at: originalText.length - 1, effectiveRange: nil) :
            defaultTextAttributes
    }

    private func measureSuffixWidth(suffix: NSAttributedString) -> CGFloat {
        let (suffixLayoutManager, _, _) = getReusableTextKit(
            containerWidth: .greatestFiniteMagnitude,
            attributedText: suffix
        )
                
        var totalWidth: CGFloat = 0
        
        suffixLayoutManager.enumerateTextSegments(
            in: suffixLayoutManager.documentRange,
            type: .standard,
            options: []
        ) { _, frame, _, _ in
            totalWidth += frame.width
            return true
        }
        
        return totalWidth
    }
    
    // MARK: - Utility Methods
        
    private func setInternalNumberOfLines(_ lines: Int) {
        internalNumberOfLines = lines
        super.numberOfLines = lines
    }
    
    // MARK: - TextKit Helper Methods
    
    /// 라인 분석 결과 구조체
    private struct LineAnalysisResult {
        let totalLineCount: Int
        let targetFragment: NSTextLineFragment?
        let allFragments: [NSTextLineFragment]
    }
    
    /// TextKit 컴포넌트 재사용 헬퍼
    /// - Parameters:
    ///   - containerWidth: 컨테이너 너비
    ///   - attributedText: 표시할 속성 문자열
    /// - Returns: 재사용 가능한 TextKit 컴포넌트 튜플
    /// - Note: 성능 최적화를 위해 TextKit 객체를 재사용하며, 설정이 변경된 경우에만 새로 생성
    private func getReusableTextKit(
        containerWidth: CGFloat,
        attributedText: NSAttributedString
    ) -> (NSTextLayoutManager, NSTextContainer, NSTextContentStorage) {
        
        // 텍스트 컨테이너 설정
        let textContainer: NSTextContainer
        if let reusableContainer = reusableTextContainer {
            reusableContainer.size = CGSize(width: containerWidth, height: .greatestFiniteMagnitude)
            textContainer = reusableContainer
        } else {
            textContainer = NSTextContainer(size: CGSize(width: containerWidth, height: .greatestFiniteMagnitude))
            reusableTextContainer = textContainer
        }
        
        textContainer.lineFragmentPadding = self.lineFragmentPadding
        textContainer.maximumNumberOfLines = 0
        textContainer.lineBreakMode = self.lineBreakMode
        
        // 레이아웃 매니저 설정
        let textLayoutManager: NSTextLayoutManager
        if let reusableManager = reusableTextLayoutManager {
            textLayoutManager = reusableManager
        } else {
            textLayoutManager = NSTextLayoutManager()
            reusableTextLayoutManager = textLayoutManager
        }
        textLayoutManager.textContainer = textContainer
        
        // 텍스트 스토리지 설정
        let textContentStorage: NSTextContentStorage
        if let reusableStorage = reusableTextContentStorage {
            reusableStorage.attributedString = attributedText
            textContentStorage = reusableStorage
        } else {
            textContentStorage = NSTextContentStorage()
            textContentStorage.attributedString = attributedText
            reusableTextContentStorage = textContentStorage
        }
        
        // 연결이 끊어진 경우 다시 연결
        if !textContentStorage.textLayoutManagers.contains(textLayoutManager) {
            textContentStorage.addTextLayoutManager(textLayoutManager)
        }
        
        return (textLayoutManager, textContainer, textContentStorage)
    }
    
    /// 텍스트 라인 분석
    /// - Parameters:
    ///   - textLayoutManager: 텍스트 레이아웃 매니저
    ///   - targetLineCount: 대상 라인 수
    /// - Returns: 라인 분석 결과 (총 라인 수, 대상 라인 프래그먼트, 모든 프래그먼트)
    /// - Note: TextKit 2의 enumerateTextLayoutFragments를 사용하여 정확한 라인 계산
    private func analyzeTextLines(
        textLayoutManager: NSTextLayoutManager,
        targetLineCount: Int
    ) -> LineAnalysisResult {
        
        var totalLineCount = 0
        var targetFragment: NSTextLineFragment?
        var allFragments: [NSTextLineFragment] = []
        
        textLayoutManager.enumerateTextLayoutFragments(
            from: textLayoutManager.documentRange.location,
            options: [.ensuresLayout]
        ) { layoutFragment in
            let lineFragments = layoutFragment.textLineFragments
            totalLineCount += lineFragments.count
            
            allFragments.append(contentsOf: lineFragments)
            
            if allFragments.count >= targetLineCount && targetFragment == nil {
                targetFragment = allFragments[targetLineCount - 1]
            }
            
            return true
        }
        
        return LineAnalysisResult(
            totalLineCount: totalLineCount,
            targetFragment: targetFragment,
            allFragments: allFragments
        )
    }
    
    /// 자르기 위치 계산
    /// - Parameters:
    ///   - targetFragment: 대상 라인 프래그먼트
    ///   - containerWidth: 컨테이너 너비
    ///   - suffixWidth: suffix 문자열 너비
    ///   - textLayoutManager: 텍스트 레이아웃 매니저
    ///   - alignedText: 정렬된 텍스트
    /// - Returns: 최적의 자르기 위치 또는 nil
    /// - Note: 줄바꿈 문자 처리와 suffix 공간 확보를 고려한 정밀한 계산
    private func calculateTruncateLocation(
        targetFragment: NSTextLineFragment,
        containerWidth: CGFloat,
        suffixWidth: CGFloat,
        textLayoutManager: NSTextLayoutManager,
        alignedText: NSAttributedString
    ) -> NSTextLocation? {
        
        let currentLineWidth = targetFragment.typographicBounds.width
        let characterRange = targetFragment.characterRange
        let targetLineText = alignedText.attributedSubstring(from: NSRange(location: characterRange.location, length: characterRange.length))
        let endsWithNewline = targetLineText.string.hasSuffix("\n")
        
        let availableWidth: CGFloat
        if endsWithNewline {
            // 줄바꿈으로 끝나는 경우, 전체 컨테이너 너비에서 suffix 공간 확보
            availableWidth = containerWidth - suffixWidth
        } else if currentLineWidth + suffixWidth <= containerWidth {
            availableWidth = currentLineWidth
        } else {
            availableWidth = containerWidth - suffixWidth
        }
        
        guard let lineStartLocation = textLayoutManager.location(textLayoutManager.documentRange.location, offsetBy: characterRange.location),
              let lineEndLocation = textLayoutManager.location(textLayoutManager.documentRange.location, offsetBy: characterRange.location + characterRange.length),
              let lineRange = NSTextRange(location: lineStartLocation, end: lineEndLocation) else {
            return nil
        }
        
        return findOptimalTruncateLocationInline(
            in: lineRange,
            availableWidth: availableWidth,
            textLayoutManager: textLayoutManager
        )
    }
    
    
    // MARK: - Private Methods
    
    private func updateDisplay() {
        guard let attributedTextToDisplay = originalAttributedText, case let availableWidth = bounds.width, availableWidth > 0 else {
            return
        }
        
        // numberOfLinesWhenCollapsed가 0이면 일반 UILabel처럼 동작
        if numberOfLinesWhenCollapsed == 0 || isExpanded {
            super.attributedText = attributedTextToDisplay
            setInternalNumberOfLines(0)
            readMoreTextRange = nil
            return
        }
        
        // 직접 truncation 처리 - 중복 계산 없이 한 번에 처리
        switch readMorePosition {
        case .end:
            displayTruncatedTextAtEnd(attributedTextToDisplay, availableWidth: availableWidth)
        case .newLine:
            displayTruncatedTextAtNewLineBeginning(attributedTextToDisplay, availableWidth: availableWidth)
        }
    }
    
    private func displayTruncatedTextAtEnd(_ attributedText: NSAttributedString, availableWidth: CGFloat) {
        guard attributedText.length > 0 && availableWidth > 0 && numberOfLinesWhenCollapsed > 0 else {
            super.attributedText = attributedText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed == 0 ? 0 : numberOfLinesWhenCollapsed)
            readMoreTextRange = nil
            return
        }
        
        let suffix = createReadMoreSuffix(from: attributedText)
        
        let result = applyReadMoreWithTextKit2(
            originalText: attributedText,
            numberOfLines: numberOfLinesWhenCollapsed,
            containerWidth: availableWidth,
            suffix: suffix
        )
            
        if result.needsTruncation,
           let (finalText, readMoreRange) = result.textAndRange {
            // 텍스트가 잘린 경우
            super.attributedText = finalText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed)
            readMoreTextRange = readMoreRange
        } else {
            // 자르기가 필요하지 않은 경우
            super.attributedText = attributedText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed == 0 ? 0 : numberOfLinesWhenCollapsed)
            readMoreTextRange = nil
        }
    }
    
    private func displayTruncatedTextAtNewLineBeginning(_ attributedText: NSAttributedString, availableWidth: CGFloat) {
        guard attributedText.length > 0 && availableWidth > 0 && numberOfLinesWhenCollapsed > 0 else {
            super.attributedText = attributedText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed == 0 ? 0 : numberOfLinesWhenCollapsed)
            readMoreTextRange = nil
            return
        }
        
        // numberOfLinesWhenCollapsed줄로 자른 후 다음 줄 맨 앞에 "더보기" 추가
        let result = applyReadMoreWithTextKit2ForNewLine(
            originalText: attributedText,
            numberOfLines: numberOfLinesWhenCollapsed,
            containerWidth: availableWidth
        )
            
        if result.needsTruncation,
           let (finalText, readMoreRange) = result.textAndRange {
            // 텍스트가 잘린 경우
            super.attributedText = finalText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed + 1) // +1줄 더 표시
            readMoreTextRange = readMoreRange
        } else {
            // 자르기가 필요하지 않은 경우
            super.attributedText = attributedText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed == 0 ? 0 : numberOfLinesWhenCollapsed)
            readMoreTextRange = nil
        }
    }
    
    private func applyReadMoreWithTextKit2ForNewLine(
        originalText: NSAttributedString,
        numberOfLines: Int,
        containerWidth: CGFloat
    ) -> TextTruncationResult {
        
        let alignedText = applyTextAlignment(to: originalText)
        let (textLayoutManager, lineAnalysis) = setupTextKitAndAnalyzeLines(
            alignedText: alignedText,
            containerWidth: containerWidth,
            targetLineCount: numberOfLines
        )
        
        guard lineAnalysis.totalLineCount >= numberOfLines,
              let targetFragment = lineAnalysis.targetFragment else {
            return .noTruncationNeeded
        }
        
        // numberOfLines 줄의 끝 위치에서 자르기
        let characterRange = targetFragment.characterRange
        let truncateOffset = characterRange.location + characterRange.length
        let truncatedSubstring = originalText.attributedSubstring(from: NSRange(location: 0, length: truncateOffset))
        
        let cleanedTruncatedText = removeTrailingNewlineIfNeeded(from: truncatedSubstring)
        
        // 새 줄에 "더보기" 추가
        let finalText = NSMutableAttributedString(attributedString: cleanedTruncatedText)
        
        // 줄바꿈 추가
        let lastAttributes = getLastTextAttributes(from: originalText)
        finalText.append(NSAttributedString(string: "\n", attributes: lastAttributes))
        
        // "더보기" 텍스트 추가 (커스텀 속성 포함)
        let readMoreStartLocation = finalText.length
        finalText.append(readMoreText)
        
        // "더보기" 부분에 커스텀 속성 추가
        let finalReadMoreRange = NSRange(location: readMoreStartLocation, length: readMoreText.length)
        finalText.addAttribute(AttributeKey.isReadMore, value: true, range: finalReadMoreRange)
        
        return .truncated(finalText, finalReadMoreRange)
    }
    
    
    private func invalidateExpandableCache() {
        cachedIsExpandable = nil
        cachedExpandableKey = nil
    }
    
    private func invalidateDisplayAndLayout() {
        invalidateExpandableCache()
        invalidateIntrinsicContentSize()
        setNeedsLayout()
        lastLayoutBounds = .zero // 레이아웃 캐시 무효화
    }
    
    private func generateExpandableCacheKey(text: String, width: CGFloat) -> String {
        let components = [
            text,
            "\(width)",
            "\(numberOfLinesWhenCollapsed)",
            "\(readMorePosition.rawValue)",
            readMoreText.string,
            ellipsisText,
            font?.fontName ?? "default",
            "\(font?.pointSize ?? 17)"
        ]
        
        let combined = components.joined(separator: "|")
        return String(combined.hashValue)
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard isExpandable, !isExpanded, let attributedText = attributedText else {
            return
        }
                
        let locationInLabel = gesture.location(in: self)
        
        // 최적화된 탭 검증: 커스텀 속성 기반 직접 검증
        guard attributedText.length > 0 && bounds.width > 0 else {
            return
        }
        
        // 텍스트 내 "더보기" 영역 체크 - 커스텀 속성 활용
        if hasReadMoreTextAtLocation(locationInLabel, in: attributedText) {
            setExpanded(true, animated: true)
        }
    }
    
    /// TextKit 2를 사용하여 탭 위치의 문자 속성 직접 확인 (newLine position 대응)
    /// - Parameters:
    ///   - location: 확인할 CGPoint 위치 (view coordinate space)
    ///   - attributedText: 속성 문자열
    /// - Returns: "더보기" 텍스트 여부
    /// - Note: newLine position에서 textLayoutFragment 실패 시 fallback 로직 포함
    private func hasReadMoreTextAtLocation(_ location: CGPoint, in attributedText: NSAttributedString) -> Bool {
        // 1. 기본 조건 확인
        guard attributedText.length > 0 else { return false }
        
        // 2. readMoreTextRange 직접 확인 (빠른 검증)
        if let readMoreRange = readMoreTextRange {
            // newLine position이나 다른 경우에도 안전한 범위 기반 검증
            return isLocationInReadMoreRange(location, attributedText: attributedText, range: readMoreRange)
        }
        
        // 3. TextKit 2 설정 및 레이아웃 수행
        let (textLayoutManager, textContainer, _) = getReusableTextKit(
            containerWidth: bounds.width,
            attributedText: attributedText
        )
        textLayoutManager.ensureLayout(for: textLayoutManager.documentRange)
        
        // 4. 좌표 공간 변환: view → text container coordinate space
        let pointInTextContainer = location
        
        // 5. TextKit 2 방식으로 layout fragment 가져오기 (newLine position 대응)
        guard let layoutFragment = textLayoutManager.textLayoutFragment(for: pointInTextContainer) else {
            // newLine position에서 textLayoutFragment 실패 시 AttributeKey.isReadMore 기반 fallback
            return searchByReadMoreAttribute(location, in: attributedText, textLayoutManager: textLayoutManager)
        }
        
        // 6. 좌표 공간 변환: text container → layout fragment coordinate space
        let pointInLayoutFragment = CGPoint(
            x: pointInTextContainer.x - layoutFragment.layoutFragmentFrame.minX,
            y: pointInTextContainer.y - layoutFragment.layoutFragmentFrame.minY
        )
        
        // 7. line fragment에서 정확한 문자 인덱스 찾기
        for lineFragment in layoutFragment.textLineFragments {
            let lineFrame = lineFragment.typographicBounds
            
            // 탭 위치가 이 라인에 포함되는지 확인
            if pointInLayoutFragment.y >= lineFrame.minY && pointInLayoutFragment.y <= lineFrame.maxY {
                let characterRange = lineFragment.characterRange
                
                // 정확한 문자 인덱스 계산 (TextKit 2 방식)
                let relativeX = max(0, pointInLayoutFragment.x - lineFrame.minX)
                let progress = min(1.0, relativeX / max(1, lineFrame.width))
                let charOffset = Int(progress * Double(characterRange.length))
                
                let characterIndex = characterRange.location + min(charOffset, characterRange.length - 1)
                
                // 8. 문자 인덱스에서 isReadMore 속성 직접 확인
                guard characterIndex >= 0, characterIndex < attributedText.length else {
                    return false
                }
                
                let attributes = attributedText.attributes(at: characterIndex, effectiveRange: nil)
                return (attributes[AttributeKey.isReadMore] as? Bool) == true
            }
        }
        
        return false
    }
    
    /// readMoreTextRange 기반 위치 검증 (newLine position 안전 처리)
    private func isLocationInReadMoreRange(_ location: CGPoint, attributedText: NSAttributedString, range: NSRange) -> Bool {
        // newLine position 특화: Y축 좌표 기반 관대한 히트 테스트
        if readMorePosition == .newLine {
            return newLinePositionHitTest(location, in: attributedText, range: range)
        }
        
        let (textLayoutManager, _, _) = getReusableTextKit(
            containerWidth: bounds.width,
            attributedText: attributedText
        )
        textLayoutManager.ensureLayout(for: textLayoutManager.documentRange)
        
        // readMoreTextRange의 실제 레이아웃 위치 계산
        var foundReadMoreArea = false
        
        textLayoutManager.enumerateTextLayoutFragments(
            from: textLayoutManager.documentRange.location,
            options: [.ensuresLayout]
        ) { layoutFragment in
            for lineFragment in layoutFragment.textLineFragments {
                let characterRange = lineFragment.characterRange
                let lineFrame = lineFragment.typographicBounds
                
                // readMoreTextRange와 겹치는 부분이 있는지 확인
                let intersection = NSIntersectionRange(characterRange, range)
                if intersection.length > 0 {
                    // 탭 위치가 이 라인에 있는지 확인 (관대한 범위)
                    if location.y >= lineFrame.minY - 10 && location.y <= lineFrame.maxY + 10 {
                        foundReadMoreArea = true
                        return false // 찾았으므로 중단
                    }
                }
            }
            return true // 계속 탐색
        }
        
        return foundReadMoreArea
    }
    
    /// newLine position 전용 히트 테스트 - Y축 기반 관대한 범위
    private func newLinePositionHitTest(_ location: CGPoint, in attributedText: NSAttributedString, range: NSRange) -> Bool {
        // newLine position에서는 "더보기"가 마지막 줄에 있으므로
        // 전체 레이블의 하단 영역에서 관대하게 히트 테스트
        let labelHeight = bounds.height
        let lineHeight = font?.lineHeight ?? 20
        
        // 마지막 1-2줄 영역에서 히트 허용 (관대한 범위)
        let lastLineAreaMinY = labelHeight - (lineHeight * 2)
        let lastLineAreaMaxY = labelHeight + 10 // 여유 공간
        
        let isInLastLineArea = location.y >= lastLineAreaMinY && location.y <= lastLineAreaMaxY
        
        return isInLastLineArea
    }
    
    
    /// textLayoutFragment 실패 시 fallback hit test (newLine position 특화)
    private func fallbackHitTest(_ location: CGPoint, in attributedText: NSAttributedString, textLayoutManager: NSTextLayoutManager) -> Bool {
        // readMoreTextRange가 nil인 경우, isReadMore 속성으로 직접 검색
        if readMoreTextRange == nil {
            return searchByReadMoreAttribute(location, in: attributedText, textLayoutManager: textLayoutManager)
        }
        
        guard let readMoreRange = readMoreTextRange else { return false }
        
        // newLine position의 경우 마지막 부분에서 더 관대하게 검사
        var isInReadMoreArea = false
        
        textLayoutManager.enumerateTextLayoutFragments(
            from: textLayoutManager.documentRange.location,
            options: [.ensuresLayout]
        ) { layoutFragment in
            for lineFragment in layoutFragment.textLineFragments {
                let characterRange = lineFragment.characterRange
                let lineFrame = lineFragment.typographicBounds
                
                // readMore 범위와 겹치는지 확인
                let intersection = NSIntersectionRange(characterRange, readMoreRange)
                if intersection.length > 0 {
                    // newLine position을 고려한 관대한 Y축 범위
                    let extendedMinY = lineFrame.minY - 15
                    let extendedMaxY = lineFrame.maxY + 15
                    
                    if location.y >= extendedMinY && location.y <= extendedMaxY {
                        isInReadMoreArea = true
                        return false // 찾았으므로 중단
                    }
                }
            }
            return true // 계속 탐색
        }
        
        return isInReadMoreArea
    }
    
    /// isReadMore 속성을 가진 문자들을 직접 검색하여 히트 테스트 (readMoreTextRange가 nil일 때)
    private func searchByReadMoreAttribute(_ location: CGPoint, in attributedText: NSAttributedString, textLayoutManager: NSTextLayoutManager) -> Bool {
        // 모든 layout fragment를 순회하며 isReadMore 속성을 가진 문자들의 위치 확인
        var foundReadMoreHit = false
        
        textLayoutManager.enumerateTextLayoutFragments(
            from: textLayoutManager.documentRange.location,
            options: [.ensuresLayout]
        ) { layoutFragment in
            for lineFragment in layoutFragment.textLineFragments {
                let characterRange = lineFragment.characterRange
                let lineFrame = lineFragment.typographicBounds
                
                // 이 라인에 탭이 있는지 확인 (Y축 관대한 범위)
                if location.y >= lineFrame.minY - 15 && location.y <= lineFrame.maxY + 15 {
                    // 이 라인의 모든 문자를 검사하여 isReadMore 속성 확인
                    for charIndex in characterRange.location..<(characterRange.location + characterRange.length) {
                        if charIndex < attributedText.length {
                            let attributes = attributedText.attributes(at: charIndex, effectiveRange: nil)
                            if (attributes[AttributeKey.isReadMore] as? Bool) == true {
                                foundReadMoreHit = true
                                return false // 찾았으므로 중단
                            }
                        }
                    }
                }
            }
            return true // 계속 탐색
        }
        
        return foundReadMoreHit
    }
    
    
    /// 주어진 인덱스의 텍스트가 "더보기" 텍스트인지 커스텀 속성으로 확인
    /// - Parameters:
    ///   - index: 확인할 문자 인덱스
    ///   - attributedText: 속성 문자열
    /// - Returns: "더보기" 텍스트 여부
    private func isReadMoreTextAtIndex(_ index: Int, in attributedText: NSAttributedString) -> Bool {
        guard index >= 0 && index < attributedText.length else {
            return false
        }
        
        // 커스텀 속성으로 "더보기" 텍스트 확인
        let attributes = attributedText.attributes(at: index, effectiveRange: nil)
        
        // isReadMore 속성이 있고 true인지 확인
        if let isReadMore = attributes[AttributeKey.isReadMore] as? Bool, isReadMore {
            return true
        }
        
        return false
    }
    
    // MARK: - Overrides
    
    public override var numberOfLines: Int {
        get {
            return numberOfLinesWhenCollapsed
        }
        set {
            numberOfLinesWhenCollapsed = newValue
        }
    }
    
    public override var lineBreakMode: NSLineBreakMode {
        didSet {
            updateDisplay()
        }
    }
    
    public override var text: String? {
        didSet {
            setOriginalText(NSAttributedString(string: text ?? ""))
        }
    }
    
    public override var attributedText: NSAttributedString? {
        get {
            return super.attributedText
        }
        set {
            setOriginalText(newValue ?? NSAttributedString())
        }
    }
    
    /// 원본 텍스트 설정 공통 로직
    /// - Parameter text: 설정할 속성 문자열
    /// - Note: 텍스트 정렬 적용, 캐시 무효화, 디스플레이 업데이트를 일괄 처리
    private func setOriginalText(_ text: NSAttributedString) {
        originalAttributedText = applyTextAlignment(to: text)
        invalidateDisplayAndLayout()
        updateDisplay()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // 크기 변경이 있을 때만 업데이트
        if bounds != lastLayoutBounds {
            lastLayoutBounds = bounds
            if bounds.width > 0 {
                invalidateExpandableCache()
                updateDisplay()
            }
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        guard let attributedText = attributedText, attributedText.length > 0 else {
            return super.intrinsicContentSize
        }
        
        let width = bounds.width > 0 ? bounds.width : Self.defaultFallbackWidth
        let size = attributedText.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
        
        return CGSize(width: size.width, height: size.height)
    }
    
    private var lineFragmentPadding: CGFloat {
        return 0.0
    }
    
    private var defaultTextAttributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[.font] = font
        attributes[.foregroundColor] = textColor
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.lineHeightMultiple = 0
        paragraphStyle.paragraphSpacing = 0
        paragraphStyle.paragraphSpacingBefore = 0
        paragraphStyle.lineBreakMode = self.lineBreakMode
        paragraphStyle.alignment = self.textAlignment
        paragraphStyle.usesDefaultHyphenation = false
        
        attributes[.paragraphStyle] = paragraphStyle
        
        return attributes
    }
    
    // MARK: - TextKit 2 Text Alignment Helper
    private func applyTextAlignment(to attributedText: NSAttributedString) -> NSAttributedString {
        let range = NSRange(location: 0, length: attributedText.length)
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
        
        // Font 속성 설정
        mutableAttributedText.addAttribute(.font, value: self.font, range: range)
        
        // 현재 정렬이 이미 올바른 경우 단락 스타일 업데이트 스킵
        if let existingStyle = attributedText.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle,
           existingStyle.alignment == self.textAlignment {
            return mutableAttributedText
        }
        
        // 단락 스타일 설정
        let paragraphStyle: NSMutableParagraphStyle
        if let existingStyle = attributedText.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
            paragraphStyle = existingStyle.mutableCopy() as! NSMutableParagraphStyle
        } else {
            paragraphStyle = NSMutableParagraphStyle()
        }
        
        paragraphStyle.alignment = self.textAlignment
        mutableAttributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        
        return mutableAttributedText
    }
}
