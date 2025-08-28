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
    
    
    public struct AttributeKey {
        public static let isReadMore = NSAttributedString.Key("ReadMoreLabel.isReadMore")
    }
    
    
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
            self.layoutIfNeeded()
        }
    }
    
    @objc public var ellipsisText: NSAttributedString = NSAttributedString(string: "..") {
        didSet {
            invalidateDisplayAndLayout()
            self.layoutIfNeeded()
        }
    }
    
    @objc public var readMorePosition: Position = .end {
        didSet {
            invalidateDisplayAndLayout()
            self.layoutIfNeeded()
        }
    }
    @objc public private(set) var isExpanded: Bool = false
    
    @objc public var isExpandable: Bool {
        if isExpanded {
            return true
        }
        
        guard numberOfLinesWhenCollapsed > 0,
              let readMoreTextRange = readMoreTextRange else {
            return false
        }
        return readMoreTextRange.length > 0
    }
    
    
    private var readMoreTextRange: NSRange?
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var originalAttributedText: NSAttributedString?
    private var internalNumberOfLines: Int = 0
    
    private static let animationDuration: TimeInterval = 0.3
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabel()
    }
    
    
    private func setupLabel() {
        setInternalNumberOfLines(numberOfLinesWhenCollapsed == 0 ? 0 : numberOfLinesWhenCollapsed)
        lineBreakMode = .byWordWrapping
        isUserInteractionEnabled = true
        setupTapGesture()
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGestureRecognizer = tapGesture
        addGestureRecognizer(tapGesture)
    }
    
    
    @objc public func expand() {
        setExpanded(true, animated: true)
    }
    
    @objc public func collapse() {
        setExpanded(false, animated: true)
    }
    
    @objc public func setExpanded(_ expanded: Bool, animated: Bool) {
        guard expanded == false || isExpandable else { 
            return 
        }
        
        guard expanded != isExpanded else { 
            return 
        }
        
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
        if isExpanded {
            setExpanded(false, animated: false)
        }
    }
    
    
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
    
    
    private enum TextTruncationResult {
        case noTruncationNeeded
        case truncated(NSAttributedString, NSRange)
        
        var needsTruncation: Bool {
            switch self {
            case .noTruncationNeeded:
                return false
            case .truncated:
                return true
            }
        }
        
        var textAndRange: (NSAttributedString, NSRange?)? {
            switch self {
            case .noTruncationNeeded:
                return nil
            case .truncated(let text, let range):
                return (text, range)
            }
        }
    }
    
    private func legacyApplyReadMore(
        originalText: NSAttributedString,
        numberOfLines: Int,
        containerWidth: CGFloat,
        suffix: NSAttributedString
    ) -> TextTruncationResult {
        
        let alignedText = applyTextAlignment(to: originalText)
        let (textStorage, layoutManager, textContainer) = createTextKitStack(for: alignedText, containerWidth: containerWidth)
        
        let totalGlyphCount = layoutManager.numberOfGlyphs
        
        guard totalGlyphCount > 0 else {
            return .noTruncationNeeded
        }
        
        // 기존 layoutManager를 재사용하여 줄 수 계산
        var actualLinesNeeded = 0
        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: totalGlyphCount)) { 
            (rect, usedRect, textContainer, glyphRange, stop) in
            actualLinesNeeded += 1
        }
        
        // 마지막 줄이 높이 0인 경우 제외
        if actualLinesNeeded > 0 {
            let lastLineGlyphIndex = totalGlyphCount - 1
            let lastLineRect = layoutManager.lineFragmentRect(forGlyphAt: lastLineGlyphIndex, effectiveRange: nil)
            
            if lastLineRect.height == 0 {
                actualLinesNeeded -= 1
            }
        }
        
        if actualLinesNeeded <= numberOfLines {
            return .noTruncationNeeded
        }
        var lastLineRange = NSRange()
        var currentLineCount = 0
        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: totalGlyphCount)) { 
            (rect, usedRect, textContainer, glyphRange, stop) in
            currentLineCount += 1
            if currentLineCount == numberOfLines {
                lastLineRange = glyphRange
                stop.pointee = true
            }
        }
        
        let lastLineRect = layoutManager.lineFragmentRect(forGlyphAt: lastLineRange.location, effectiveRange: nil)
        let lastLineWidth = lastLineRect.width
        
        let suffixWidth = calculateTextSize(for: suffix, width: CGFloat.greatestFiniteMagnitude).width
        let truncateCharacterIndex: Int
        if lastLineWidth + suffixWidth > containerWidth {
            let availableWidth = containerWidth - suffixWidth
            truncateCharacterIndex = findTruncateLocationWithWidth(availableWidth, in: lastLineRange, layoutManager: layoutManager)
        } else {
            let characterRange = layoutManager.characterRange(forGlyphRange: lastLineRange, actualGlyphRange: nil)
            truncateCharacterIndex = characterRange.location + characterRange.length
        }
        
        let truncatedText = originalText.attributedSubstring(from: NSRange(location: 0, length: truncateCharacterIndex))
        let cleanedTruncatedText = removeTrailingNewlineIfNeeded(from: truncatedText)
        let finalText = NSMutableAttributedString(attributedString: cleanedTruncatedText)
        finalText.append(suffix)
        
        let readMoreRange = NSRange(location: cleanedTruncatedText.length, length: suffix.length)
        
        return .truncated(finalText, readMoreRange)
    }
    
    private func findTruncateLocationWithWidth(_ targetWidth: CGFloat, in glyphRange: NSRange, layoutManager: NSLayoutManager) -> Int {
        let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
        
        let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphRange.location, effectiveRange: nil)
        
        let targetPoint = CGPoint(x: lineRect.origin.x + targetWidth, y: lineRect.midY)
        
        let characterIndex = layoutManager.characterIndex(
            for: targetPoint,
            in: layoutManager.textContainers[0],
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        let clampedIndex = max(characterRange.location, 
                              min(characterIndex, characterRange.location + characterRange.length))
        
        return clampedIndex
    }
    
    private func createReadMoreSuffix(from originalText: NSAttributedString) -> NSAttributedString {
        let lastAttributes = originalText.lastTextAttributes(defaultAttributes: defaultTextAttributes)
        
        let suffix = NSMutableAttributedString()
        
        let ellipsisWithLastAttributes = ellipsisText.createMutableWithAttributes(lastAttributes)
        
        suffix.append(ellipsisWithLastAttributes)
        suffix.append(NSAttributedString(string: " ", attributes: lastAttributes))
        let readMoreStartLocation = suffix.length
        
        let readMoreWithOriginalAttributes = readMoreText.createMutableWithAttributes(lastAttributes)
        
        suffix.append(readMoreWithOriginalAttributes)
        let readMoreRange = NSRange(location: readMoreStartLocation, length: readMoreWithOriginalAttributes.length)
        suffix.addAttribute(AttributeKey.isReadMore, value: true, range: readMoreRange)
        
        return suffix
    }
    private func removeTrailingNewlineIfNeeded(from attributedString: NSAttributedString) -> NSAttributedString {
        let mutableString = NSMutableAttributedString(attributedString: attributedString)
        if mutableString.string.hasSuffix("\n") {
            let newLength = mutableString.length - 1
            mutableString.deleteCharacters(in: NSRange(location: newLength, length: 1))
        }
        return mutableString
    }
        
    private func setInternalNumberOfLines(_ lines: Int) {
        internalNumberOfLines = lines
        super.numberOfLines = lines
    }
    
    // MARK: - TextKit Helper Methods
    
    /// Creates a new TextKit stack for text measurement and layout
    /// Each call returns fresh objects to avoid lifecycle issues
    private func createTextKitStack(
        for attributedText: NSAttributedString,
        containerWidth: CGFloat
    ) -> (textStorage: NSTextStorage, layoutManager: NSLayoutManager, textContainer: NSTextContainer) {
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: containerWidth, height: .greatestFiniteMagnitude))
        
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        textContainer.lineFragmentPadding = lineFragmentPadding
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = 0
        
        layoutManager.ensureLayout(for: textContainer)
        
        return (textStorage, layoutManager, textContainer)
    }
    
    
    private func updateDisplay() {
        guard let attributedTextToDisplay = originalAttributedText, case let availableWidth = bounds.width, availableWidth > 0 else {
            return
        }
        
        if numberOfLinesWhenCollapsed == 0 || isExpanded {
            super.attributedText = attributedTextToDisplay
            setInternalNumberOfLines(0)
            readMoreTextRange = nil
            invalidateIntrinsicContentSize()
            return
        }
                
        switch readMorePosition {
        case .end:
            displayTruncatedTextAtEnd(attributedTextToDisplay, availableWidth: availableWidth)
        case .newLine:
            displayTruncatedTextAtNewLineBeginning(attributedTextToDisplay, availableWidth: availableWidth)
        }
    }
    
    private func displayTruncatedTextAtEnd(_ attributedText: NSAttributedString, availableWidth: CGFloat) {
        print("🔍 DEBUG: displayTruncatedTextAtEnd called")
        print("   - availableWidth: \(availableWidth)")
        print("   - numberOfLinesWhenCollapsed: \(numberOfLinesWhenCollapsed)")
        
        guard attributedText.length > 0 && availableWidth > 0 && numberOfLinesWhenCollapsed > 0 else {
            print("   - Early exit: guard condition failed")
            super.attributedText = attributedText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed == 0 ? 0 : numberOfLinesWhenCollapsed)
            readMoreTextRange = nil
            return
        }
        
        let suffix = createReadMoreSuffix(from: attributedText)
        print("   - suffix created: '\(suffix.string)'")
        
        print("   - Calling NEW applyReadMore (not legacy)")
        let result = applyReadMore(
            originalText: attributedText,
            numberOfLines: numberOfLinesWhenCollapsed,
            containerWidth: availableWidth,
            suffix: suffix
        )
            
        if result.needsTruncation,
           let (finalText, readMoreRange) = result.textAndRange {
            super.attributedText = finalText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed)
            readMoreTextRange = readMoreRange
        } else {
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
        let result = applyReadMoreForNewLine(
            originalText: attributedText,
            numberOfLines: numberOfLinesWhenCollapsed,
            containerWidth: availableWidth
        )
        
        
        if result.needsTruncation,
           let (finalText, readMoreRange) = result.textAndRange {
            // newLine position에서는 항상 numberOfLines + 1줄 표시
            super.attributedText = finalText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed + 1)
            readMoreTextRange = readMoreRange
            
        } else {
            super.attributedText = attributedText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed == 0 ? 0 : numberOfLinesWhenCollapsed)
            readMoreTextRange = nil
        }
    }
    
    private func legacyApplyReadMoreForNewLine(
        originalText: NSAttributedString,
        numberOfLines: Int,
        containerWidth: CGFloat
    ) -> TextTruncationResult {
        
        let alignedText = applyTextAlignment(to: originalText)
        let (textStorage, layoutManager, textContainer) = createTextKitStack(for: alignedText, containerWidth: containerWidth)
        
        let totalGlyphCount = layoutManager.numberOfGlyphs
        
        guard totalGlyphCount > 0 else {
            return .noTruncationNeeded
        }
        
        // 단일 패스로 라인 정보 수집 및 분석
        var lineFragments: [(rect: CGRect, glyphRange: NSRange)] = []
        
        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: totalGlyphCount)) { 
            (rect, usedRect, textContainer, glyphRange, stop) in
            
            // 높이 0인 마지막 줄 제외 처리
            if rect.height > 0 {
                lineFragments.append((rect: rect, glyphRange: glyphRange))
            }
        }
        
        let actualLinesNeeded = lineFragments.count
        
        // Early exit: 잘림 불필요
        if actualLinesNeeded <= numberOfLines {
            return .noTruncationNeeded
        }
        
        // 타겟 라인 정보 추출
        guard numberOfLines <= lineFragments.count else {
            return .noTruncationNeeded
        }
        
        let targetLineFragment = lineFragments[numberOfLines - 1]
        let lastLineRange = targetLineFragment.glyphRange
        let lastLineRect = targetLineFragment.rect
        let characterRange = layoutManager.characterRange(forGlyphRange: lastLineRange, actualGlyphRange: nil)
        
        // 더보기 텍스트 생성 및 크기 계산
        let lastAttributes = originalText.lastTextAttributes(defaultAttributes: defaultTextAttributes)
        let readMoreWithNewLine = NSMutableAttributedString(string: "\n", attributes: lastAttributes)
        let readMoreWithOriginalAttributes = readMoreText.createMutableWithAttributes(lastAttributes)
        readMoreWithNewLine.append(readMoreWithOriginalAttributes)
        
        // newLine position에서는 현재 줄에서 "더보기" 공간을 확보할 필요 없음
        // numberOfLines번째 줄의 끝에서 텍스트를 자름
        let truncateOffset = characterRange.location + characterRange.length
        
        // 최종 텍스트 구성
        let truncatedSubstring = originalText.attributedSubstring(from: NSRange(location: 0, length: truncateOffset))
        let cleanedTruncatedText = removeTrailingNewlineIfNeeded(from: truncatedSubstring)
        let finalText = NSMutableAttributedString(attributedString: cleanedTruncatedText)
        
        finalText.append(NSAttributedString(string: "\n", attributes: lastAttributes))
        let readMoreStartLocation = finalText.length
        finalText.append(readMoreWithOriginalAttributes)
        
        let finalReadMoreRange = NSRange(location: readMoreStartLocation, length: readMoreWithOriginalAttributes.length)
        finalText.addAttribute(AttributeKey.isReadMore, value: true, range: finalReadMoreRange)
        
        return .truncated(finalText, finalReadMoreRange)
    }
    
    // MARK: - Optimized New Implementations (Phase 1)
    
    /// 새로운 최적화된 applyReadMore 구현 - Extension의 공통 메서드 사용
    private func applyReadMore(
        originalText: NSAttributedString,
        numberOfLines: Int,
        containerWidth: CGFloat,
        suffix: NSAttributedString
    ) -> TextTruncationResult {
        
        print("🚨 DEBUG: NEW applyReadMore called")
        print("   - numberOfLines: \(numberOfLines)")
        print("   - containerWidth: \(containerWidth)")
        
        let alignedText = applyTextAlignment(to: originalText)
        
        // Extension의 라인 분석 메서드 사용
        print("   - Calling Extension analyzeLineFragments...")
        let (totalLines, targetFragment) = analyzeLineFragments(
            for: alignedText,
            containerWidth: containerWidth,
            targetLineIndex: numberOfLines - 1
        )
        
        print("   - totalLines: \(totalLines), targetFragment exists: \(targetFragment != nil)")
        
        // 잘림 불필요한 경우
        if totalLines <= numberOfLines {
            print("   - Result: .noTruncationNeeded (totalLines \(totalLines) <= numberOfLines \(numberOfLines))")
            return .noTruncationNeeded
        }
        
        guard let targetLineFragment = targetFragment else {
            print("   - Result: .noTruncationNeeded (no targetFragment)")
            return .noTruncationNeeded
        }
        
        print("   - Needs truncation, proceeding with calculation...")
        
        // Extension의 최적화된 TextKit 스택 사용
        let (_, layoutManager, _) = createOptimizedTextKitStack(for: alignedText, containerWidth: containerWidth)
        
        let lastLineRange = targetLineFragment.glyphRange
        let lastLineRect = targetLineFragment.rect
        let lastLineWidth = lastLineRect.width
        
        let suffixWidth = calculateTextSizeWithOptimizedTextKit(for: suffix, containerWidth: CGFloat.greatestFiniteMagnitude).width
        let truncateCharacterIndex: Int
        
        print("   - lastLineWidth: \(lastLineWidth)")
        print("   - suffixWidth: \(suffixWidth)")
        print("   - containerWidth: \(containerWidth)")
        
        if lastLineWidth + suffixWidth > containerWidth {
            print("   - Need to truncate: \(lastLineWidth) + \(suffixWidth) > \(containerWidth)")
            let availableWidth = containerWidth - suffixWidth
            truncateCharacterIndex = findTruncateLocationWithWidth(availableWidth, in: lastLineRange, layoutManager: layoutManager)
        } else {
            print("   - Enough space: \(lastLineWidth) + \(suffixWidth) <= \(containerWidth)")
            let characterRange = layoutManager.characterRange(forGlyphRange: lastLineRange, actualGlyphRange: nil)
            truncateCharacterIndex = characterRange.location + characterRange.length
        }
        
        print("   - truncateCharacterIndex: \(truncateCharacterIndex)")
        
        let truncatedText = originalText.attributedSubstring(from: NSRange(location: 0, length: truncateCharacterIndex))
        let cleanedTruncatedText = removeTrailingNewlineIfNeeded(from: truncatedText)
        let finalText = NSMutableAttributedString(attributedString: cleanedTruncatedText)
        finalText.append(suffix)
        
        let readMoreRange = NSRange(location: cleanedTruncatedText.length, length: suffix.length)
        
        print("   - Final result: .truncated, readMoreRange: \(readMoreRange)")
        print("   - Final text: '\(finalText.string)'")
        
        return .truncated(finalText, readMoreRange)
    }
    
    /// 새로운 최적화된 applyReadMoreForNewLine 구현 - Extension의 공통 메서드 사용
    private func applyReadMoreForNewLine(
        originalText: NSAttributedString,
        numberOfLines: Int,
        containerWidth: CGFloat
    ) -> TextTruncationResult {
        
        let alignedText = applyTextAlignment(to: originalText)
        
        // Extension의 라인 분석 메서드 사용
        let (totalLines, targetFragment) = analyzeLineFragments(
            for: alignedText,
            containerWidth: containerWidth,
            targetLineIndex: numberOfLines - 1
        )
        
        // 잘림 불필요한 경우
        if totalLines <= numberOfLines {
            return .noTruncationNeeded
        }
        
        guard let targetLineFragment = targetFragment else {
            return .noTruncationNeeded
        }
        
        // Extension의 최적화된 TextKit 스택 사용
        let (_, layoutManager, _) = createOptimizedTextKitStack(for: alignedText, containerWidth: containerWidth)
        
        let lastLineRange = targetLineFragment.glyphRange
        let characterRange = layoutManager.characterRange(forGlyphRange: lastLineRange, actualGlyphRange: nil)
        
        // 더보기 텍스트 생성 및 크기 계산
        let lastAttributes = originalText.lastTextAttributes(defaultAttributes: defaultTextAttributes)
        let readMoreWithOriginalAttributes = readMoreText.createMutableWithAttributes(lastAttributes)
        
        // numberOfLines번째 줄의 끝에서 텍스트를 자름
        let truncateOffset = characterRange.location + characterRange.length
        
        // 최종 텍스트 구성
        let truncatedSubstring = originalText.attributedSubstring(from: NSRange(location: 0, length: truncateOffset))
        let cleanedTruncatedText = removeTrailingNewlineIfNeeded(from: truncatedSubstring)
        let finalText = NSMutableAttributedString(attributedString: cleanedTruncatedText)
        
        finalText.append(NSAttributedString(string: "\n", attributes: lastAttributes))
        let readMoreStartLocation = finalText.length
        finalText.append(readMoreWithOriginalAttributes)
        
        let finalReadMoreRange = NSRange(location: readMoreStartLocation, length: readMoreWithOriginalAttributes.length)
        finalText.addAttribute(AttributeKey.isReadMore, value: true, range: finalReadMoreRange)
        
        return .truncated(finalText, finalReadMoreRange)
    }
    
    /// 새로운 최적화된 실제 필요 라인 수 계산 - Extension 메서드 사용
    private func calculateActualLinesNeeded(for text: NSAttributedString, width: CGFloat) -> Int {
        return calculateLineCountWithTextKit(for: text, containerWidth: width)
    }
    
    /// 새로운 최적화된 텍스트 크기 계산 - Extension 메서드 사용
    private func calculateTextSize(for text: NSAttributedString, width: CGFloat) -> CGSize {
        return calculateTextSizeWithOptimizedTextKit(for: text, containerWidth: width)
    }
    
    // MARK: - TextKit 최적화 헬퍼 메서드
    
    /// TextKit 스택을 재사용하여 텍스트 크기 계산 (boundingRect 대체)
    private func calculateTextSizeWithTextKit(
        for text: NSAttributedString,
        layoutManager: NSLayoutManager,
        textContainer: NSTextContainer
    ) -> CGSize {
        // 기존 스택 업데이트
        layoutManager.textStorage?.setAttributedString(text)
        layoutManager.ensureLayout(for: textContainer)
        
        let usedRect = layoutManager.usedRect(for: textContainer)
        return usedRect.size
    }
    
    /// TextKit을 사용한 최적 잘림 위치 계산 (boundingRect 루프 대체)
    private func findOptimalTruncatePointWithTextKit(
        layoutManager: NSLayoutManager,
        characterRange: NSRange,
        availableWidth: CGFloat,
        containerWidth: CGFloat,
        textContainer: NSTextContainer
    ) -> Int {
        // 마지막 줄의 시작 위치에서 사용 가능한 너비만큼의 지점 찾기
        let lineRect = layoutManager.lineFragmentRect(forGlyphAt: layoutManager.glyphRange(forCharacterRange: characterRange, actualCharacterRange: nil).location, effectiveRange: nil)
        let targetX = lineRect.origin.x + availableWidth
        let targetPoint = CGPoint(x: targetX, y: lineRect.midY)
        
        let characterIndex = layoutManager.characterIndex(
            for: targetPoint,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // 범위 내로 제한
        let clampedIndex = max(characterRange.location, 
                              min(characterIndex, characterRange.location + characterRange.length))
        
        return clampedIndex
    }
    
    /// 기존 TextKit 스택을 재사용한 라인 수 계산
    private func calculateLinesWithExistingStack(
        _ text: NSAttributedString, 
        layoutManager: NSLayoutManager,
        textContainer: NSTextContainer
    ) -> Int {
        // 기존 스택 업데이트
        layoutManager.textStorage?.setAttributedString(text)
        layoutManager.ensureLayout(for: textContainer)
        
        var lineCount = 0
        let totalGlyphCount = layoutManager.numberOfGlyphs
        
        guard totalGlyphCount > 0 else { return 0 }
        
        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: totalGlyphCount)) { 
            (rect, _, _, _, _) in
            if rect.height > 0 { 
                lineCount += 1 
            }
        }
        
        return lineCount
    }
    
    
    private func invalidateDisplayAndLayout() {
        invalidateIntrinsicContentSize()
        setNeedsLayout()
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

        
    public override var numberOfLines: Int {
        get {
            return numberOfLinesWhenCollapsed
        }
        set {
            if !isExpanded {
                numberOfLinesWhenCollapsed = newValue
            }
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
    
    private func setOriginalText(_ text: NSAttributedString) {
        originalAttributedText = applyTextAlignment(to: text)
        invalidateDisplayAndLayout()
        updateDisplay()
    }
    
    private func checkAndResetExpandedStateIfNeeded() {
        guard let originalText = originalAttributedText,
              numberOfLinesWhenCollapsed > 0,
              bounds.width > 0 else {
            return
        }
        
        let actualLinesNeeded = calculateActualLinesNeeded(for: originalText, width: bounds.width)
        
        if actualLinesNeeded <= max(2, numberOfLinesWhenCollapsed - 1) {
            isExpanded = false
        } else {
            super.attributedText = originalText
            setInternalNumberOfLines(0)
            readMoreTextRange = nil
            invalidateIntrinsicContentSize()
        }
    }
    
    private func legacyCalculateActualLinesNeeded(for text: NSAttributedString, width: CGFloat) -> Int {
        let alignedText = applyTextAlignment(to: text)
        let (textStorage, layoutManager, textContainer) = createTextKitStack(for: alignedText, containerWidth: width)
        
        let totalGlyphCount = layoutManager.numberOfGlyphs
        
        guard totalGlyphCount > 0 else {
            return 0
        }
        
        var lineCount = 0
        
        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: totalGlyphCount)) { 
            (rect, usedRect, textContainer, glyphRange, stop) in
            lineCount += 1
        }
        
        if lineCount > 0 {
            let lastLineGlyphIndex = totalGlyphCount - 1
            let lastLineRect = layoutManager.lineFragmentRect(forGlyphAt: lastLineGlyphIndex, effectiveRange: nil)
            
            if lastLineRect.height == 0 {
                lineCount -= 1
            }
        }
        
        return lineCount
    }
    
    private func legacyCalculateTextSize(for text: NSAttributedString, width: CGFloat) -> CGSize {
        let alignedText = applyTextAlignment(to: text)
        let (textStorage, layoutManager, textContainer) = createTextKitStack(for: alignedText, containerWidth: width)
        
        let usedRect = layoutManager.usedRect(for: textContainer)
        return usedRect.size
    }
    
    private func checkAndResetTruncationStateIfNeeded() {
        guard let originalText = originalAttributedText,
              numberOfLinesWhenCollapsed > 0,
              bounds.width > 0 else {
            return
        }

        switch readMorePosition {
        case .end:
            displayTruncatedTextAtEnd(originalText, availableWidth: bounds.width)
        case .newLine:
            displayTruncatedTextAtNewLineBeginning(originalText, availableWidth: bounds.width)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if isExpanded {
            checkAndResetExpandedStateIfNeeded()
        } else {
            checkAndResetTruncationStateIfNeeded()
        }
    }
    
//    public override var intrinsicContentSize: CGSize {
//        guard let attributedText = attributedText, attributedText.length > 0 else {
//            return super.intrinsicContentSize
//        }
//        
//        let width = bounds.width
//        let size = calculateTextSizeWithNumberOfLines(for: attributedText, width: width, numberOfLines: super.numberOfLines)
//        
//        return CGSize(width: size.width, height: size.height)
//    }
    
    private func calculateTextSizeWithNumberOfLines(for attributedText: NSAttributedString, width: CGFloat, numberOfLines: Int) -> CGSize {
        guard width > 0 else { return .zero }
        
        let (textStorage, layoutManager, textContainer) = createTextKitStack(for: attributedText, containerWidth: width)
        let usedRect = layoutManager.usedRect(for: textContainer)
        
        return CGSize(width: ceil(usedRect.width), height: ceil(usedRect.height))
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
    
    private func hasReadMoreTextAtLocation(_ location: CGPoint, in attributedText: NSAttributedString) -> Bool {
        guard attributedText.length > 0, let readMoreRange = readMoreTextRange else {
            return false
        }
        
        let (textStorage, layoutManager, textContainer) = createTextKitStack(for: attributedText, containerWidth: bounds.width)
        
        let readMoreStartIndex = readMoreRange.location
        
        if readMorePosition == .newLine && readMoreStartIndex > 0 {
            let stringIndex = attributedText.string.index(attributedText.string.startIndex, offsetBy: readMoreStartIndex - 1)
            let previousChar = attributedText.string[stringIndex]
            if previousChar == "\n" {
                let lineRect = layoutManager.lineFragmentRect(forGlyphAt: readMoreStartIndex, effectiveRange: nil)
                return lineRect.contains(location)
            }
        }
        let usedRect = layoutManager.usedRect(for: textContainer)
        let clampedLocation = CGPoint(
            x: max(0, min(location.x, usedRect.maxX)),
            y: max(0, min(location.y, usedRect.maxY))
        )
        
        let characterIndex = layoutManager.characterIndex(
            for: clampedLocation,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        guard characterIndex != NSNotFound,
              characterIndex >= 0,
              characterIndex < attributedText.length,
              NSLocationInRange(characterIndex, readMoreRange) else {
            return false
        }
        let attributes = attributedText.attributes(at: characterIndex, effectiveRange: nil)
        return (attributes[AttributeKey.isReadMore] as? Bool) == true
    }
    
    private func applyTextAlignment(to attributedText: NSAttributedString) -> NSAttributedString {
        let range = NSRange(location: 0, length: attributedText.length)
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
        
        mutableAttributedText.addAttribute(.font, value: self.font, range: range)
        
        if let existingStyle = attributedText.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle,
           existingStyle.alignment == self.textAlignment {
            return mutableAttributedText
        }
        
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

// MARK: - ReadMoreLabel TextKit Extensions

private extension ReadMoreLabel {
    
    /// TextKit 스택을 재사용 가능한 형태로 생성하는 통합 메서드
    /// 메모리 효율성을 위해 각 호출마다 새로운 스택을 생성하되, 설정은 일관성 있게 적용
    func createOptimizedTextKitStack(
        for attributedText: NSAttributedString,
        containerWidth: CGFloat
    ) -> (textStorage: NSTextStorage, layoutManager: NSLayoutManager, textContainer: NSTextContainer) {
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: containerWidth, height: .greatestFiniteMagnitude))
        
        // 표준화된 TextKit 스택 연결
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        // 통일된 컨테이너 설정
        textContainer.lineFragmentPadding = lineFragmentPadding
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = 0
        
        // 레이아웃 보장
        layoutManager.ensureLayout(for: textContainer)
        
        return (textStorage, layoutManager, textContainer)
    }
    
    /// 공통 라인 수 계산 로직 - 높이 0인 라인 제외 처리 포함
    func calculateLineCountWithTextKit(
        for attributedText: NSAttributedString,
        containerWidth: CGFloat
    ) -> Int {
        let alignedText = applyTextAlignment(to: attributedText)
        let (_, layoutManager, _) = createOptimizedTextKitStack(for: alignedText, containerWidth: containerWidth)
        
        let totalGlyphCount = layoutManager.numberOfGlyphs
        guard totalGlyphCount > 0 else { return 0 }
        
        var lineCount = 0
        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: totalGlyphCount)) { 
            (rect, _, _, _, _) in
            if rect.height > 0 {
                lineCount += 1
            }
        }
        
        return lineCount
    }
    
    /// 공통 텍스트 크기 계산 로직 - TextKit 기반
    func calculateTextSizeWithOptimizedTextKit(
        for attributedText: NSAttributedString,
        containerWidth: CGFloat
    ) -> CGSize {
        let alignedText = applyTextAlignment(to: attributedText)
        let (_, layoutManager, textContainer) = createOptimizedTextKitStack(for: alignedText, containerWidth: containerWidth)
        
        let usedRect = layoutManager.usedRect(for: textContainer)
        return CGSize(width: ceil(usedRect.width), height: ceil(usedRect.height))
    }
    
    /// 라인 단위 분석을 위한 공통 메서드
    func analyzeLineFragments(
        for attributedText: NSAttributedString,
        containerWidth: CGFloat,
        targetLineIndex: Int
    ) -> (totalLines: Int, targetLineFragment: (rect: CGRect, glyphRange: NSRange)?) {
        print("     🔧 Extension: analyzeLineFragments called")
        print("       - containerWidth: \(containerWidth)")
        print("       - targetLineIndex: \(targetLineIndex)")
        
        let alignedText = applyTextAlignment(to: attributedText)
        let (_, layoutManager, _) = createOptimizedTextKitStack(for: alignedText, containerWidth: containerWidth)
        
        let totalGlyphCount = layoutManager.numberOfGlyphs
        guard totalGlyphCount > 0 else { return (0, nil) }
        
        var lineFragments: [(rect: CGRect, glyphRange: NSRange)] = []
        
        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: totalGlyphCount)) { 
            (rect, _, _, glyphRange, _) in
            if rect.height > 0 {
                lineFragments.append((rect: rect, glyphRange: glyphRange))
            }
        }
        
        let targetFragment = targetLineIndex < lineFragments.count ? lineFragments[targetLineIndex] : nil
        
        print("       - totalGlyphCount: \(totalGlyphCount)")
        print("       - lineFragments.count: \(lineFragments.count)")  
        print("       - targetFragment found: \(targetFragment != nil)")
        
        return (lineFragments.count, targetFragment)
    }
}

// MARK: - NSAttributedString Extensions

private extension NSAttributedString {
    /// Creates a mutable attributed string with base attributes, then merges source attributes
    /// The source attributes will override base attributes where they conflict
    func createMutableWithAttributes(_ baseAttributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
        let mutableString = NSMutableAttributedString(attributedString: self)
        
        // Add base attributes only where they don't already exist
        enumerateAttributes(in: NSRange(location: 0, length: length), options: []) { existingAttributes, range, _ in
            var attributesToAdd: [NSAttributedString.Key: Any] = [:]
            
            for (key, value) in baseAttributes {
                if existingAttributes[key] == nil {
                    attributesToAdd[key] = value
                }
            }
            
            for (key, value) in attributesToAdd {
                mutableString.addAttribute(key, value: value, range: range)
            }
        }
        
        return mutableString
    }
    
    /// Gets the attributes from the last character, or returns default attributes if string is empty
    func lastTextAttributes(defaultAttributes: [NSAttributedString.Key: Any] = [:]) -> [NSAttributedString.Key: Any] {
        if length > 0 {
            return attributes(at: length - 1, effectiveRange: nil)
        } else {
            return defaultAttributes
        }
    }
}
