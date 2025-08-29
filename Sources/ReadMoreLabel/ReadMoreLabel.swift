import UIKit

@available(iOS 16.0, *)
@objc public protocol ReadMoreLabelDelegate: AnyObject {
    @objc optional func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool)
}

/**
 A customizable UILabel subclass that provides "Read More" functionality for long text content.
 
 ## Features
 - **Smart Truncation**: Accurately truncates text to specified line count with pixel-perfect calculations
 - **Interactive Expansion**: Tap to expand/collapse between truncated and full text states
 - **Flexible Positioning**: Choose between `.end` (same line) or `.newLine` positioning for "Read More" button
 - **TextKit 1 Integration**: Uses proven TextKit 1 APIs for reliable text measurement and layout
 - **Customizable Styling**: Support for attributed strings, custom ellipsis, and "Read More" text styling
 - **Delegate Support**: Receive callbacks when expansion state changes
 
 ## Usage
 ```swift
 let label = ReadMoreLabel()
 label.numberOfLinesWhenCollapsed = 3
 label.readMoreText = NSAttributedString(string: "Read More...", attributes: [
     .foregroundColor: UIColor.blue,
     .font: UIFont.systemFont(ofSize: 16, weight: .medium)
 ])
 label.text = "Your long text content here..."
 label.delegate = self
 ```
 
 ## Requirements
 - iOS 16.0+
 - Swift 5.0+
 
 ## Performance
 - Optimized TextKit stack reuse for better memory efficiency
 - Consolidated enumeration operations to minimize layout passes
 - Accurate width calculations using `lineFragmentUsedRect` for pixel-perfect text positioning
 
 - Author: ReadMoreLabel Development Team
 - Version: 2.0.0 (Phase 2 Optimizations)
 */
@available(iOS 16.0, *)
@objc @IBDesignable
public class ReadMoreLabel: UILabel {
    
    /// Positioning options for "Read More" text
    @objc public enum Position: Int {
        /// Position "Read More" at the end of the truncated text (same line)
        case end = 0
        /// Position "Read More" on a new line below the truncated text
        case newLine = 1
    }
    
    /// Attribute keys used internally for text styling and hit testing
    public struct AttributeKey {
        /// Attribute key to mark "Read More" text ranges for tap detection
        public static let isReadMore = NSAttributedString.Key("ReadMoreLabel.isReadMore")
    }
    
    /// Delegate to receive expansion state change notifications
    @objc public weak var delegate: ReadMoreLabelDelegate?
    
    /**
     Number of lines to show when the label is in collapsed state.
     
     - **Default**: 3 lines
     - **Range**: 0+ (values < 0 are automatically clamped to 0)
     - **Special Value**: Setting to 0 disables truncation entirely
     
     This property is IBInspectable, allowing configuration directly in Interface Builder.
     
     ## Example
     ```swift
     label.numberOfLinesWhenCollapsed = 2  // Show 2 lines when collapsed
     label.numberOfLinesWhenCollapsed = 0  // Disable truncation (show all text)
     ```
     */
    @IBInspectable @objc public var numberOfLinesWhenCollapsed: Int = 3 {
        didSet {
            let finalValue = max(0, numberOfLinesWhenCollapsed)
            if finalValue != numberOfLinesWhenCollapsed {
                numberOfLinesWhenCollapsed = finalValue
                return
            }
            invalidateLayoutCache()
            invalidateDisplayAndLayout()
        }
    }
    
    /**
     The attributed text displayed as the "Read More" button.
     
     Default is "더보기.." with default text attributes.
     Customize with your desired styling:
     ```swift
     label.readMoreText = NSAttributedString(string: "Read More", attributes: [
         .foregroundColor: UIColor.blue,
         .font: UIFont.boldSystemFont(ofSize: 16)
     ])
     ```
     */
    @objc public var readMoreText: NSAttributedString = NSAttributedString(string: "더보기..") {
        didSet {
            invalidateLayoutCache()
            invalidateDisplayAndLayout()
            self.layoutIfNeeded()
        }
    }
    
    /**
     The ellipsis text inserted before the "Read More" button.
     
     Default is ".." to create a natural ".. 더보기.." appearance.
     Set to empty string to remove ellipsis entirely.
     */
    @objc public var ellipsisText: NSAttributedString = NSAttributedString(string: "..") {
        didSet {
            invalidateLayoutCache()
            invalidateDisplayAndLayout()
            self.layoutIfNeeded()
        }
    }
    
    /**
     Position of the "Read More" text relative to truncated content.
     
     - `.end`: Position at the end of the last visible line (space permitting)
     - `.newLine`: Always position on a new line below the truncated text
     
     Default is `.end` for compact display.
     This property is IBInspectable for Interface Builder configuration.
     */
    @IBInspectable @objc public var readMorePosition: Position = .end {
        didSet {
            invalidateLayoutCache()
            invalidateDisplayAndLayout()
            self.layoutIfNeeded()
        }
    }
    
    /// Current expansion state - `true` when full text is visible, `false` when truncated
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
    
    
    /**
     Duration of expand/collapse animations in seconds.
     
     - **Default**: 0.3 seconds
     - **Range**: 0.0 - 2.0 seconds (values outside this range are clamped)
     
     Set to 0 for instant transitions without animation.
     This property is IBInspectable for Interface Builder configuration.
     
     ## Example
     ```swift
     label.animationDuration = 0.5  // Slower animation
     label.animationDuration = 0.0  // Instant transition
     ```
     */
    @IBInspectable @objc public var animationDuration: TimeInterval = 0.3 {
        didSet {
            animationDuration = max(0.0, min(2.0, animationDuration))
        }
    }
    
    /**
     Custom accessibility label for the "Read More" action.
     
     - **Default**: nil (uses system default)
     - **Usage**: Provide localized accessibility labels for better VoiceOver support
     
     When nil, the system will use the visible "Read More" text for accessibility.
     Set this property to provide more descriptive accessibility labels.
     
     ## Example
     ```swift
     label.readMoreAccessibilityLabel = "Read full article"
     label.collapseAccessibilityLabel = "Show less content"
     ```
     */
    @objc public var readMoreAccessibilityLabel: String?
    
    /**
     Custom accessibility label for the "Collapse" action.
     
     - **Default**: nil (uses "Show less" or similar system default)
     */
    @objc public var collapseAccessibilityLabel: String?
    
    // MARK: - Private Properties
    private var readMoreTextRange: NSRange?
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var originalAttributedText: NSAttributedString?
    private var internalNumberOfLines: Int = 0
    
    // MARK: - Performance Caching
    private struct LayoutCache {
        let text: NSAttributedString
        let bounds: CGRect
        let numberOfLines: Int
        let truncationResult: TextTruncationResult
        
        func isValidFor(text: NSAttributedString, bounds: CGRect, numberOfLines: Int) -> Bool {
            return self.text.isEqual(to: text) &&
                   self.bounds == bounds &&
                   self.numberOfLines == numberOfLines
        }
    }
    
    private var layoutCache: LayoutCache?
    
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
        setupAccessibility()
    }
    
    private func setupAccessibility() {
        // Enable accessibility for the label
        isAccessibilityElement = true
        accessibilityTraits = [.staticText, .button]
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGestureRecognizer = tapGesture
        addGestureRecognizer(tapGesture)
    }
    
    
    /// Expands the label to show full text with animation
    @objc public func expand() {
        setExpanded(true, animated: true)
    }
    
    /// Collapses the label to truncated state with animation  
    @objc public func collapse() {
        setExpanded(false, animated: true)
    }
    
    /**
     Programmatically sets the expansion state with optional animation.
     
     - Parameters:
        - expanded: `true` to show full text, `false` to show truncated text
        - animated: Whether to animate the transition (default animation duration: 0.3s)
     
     - Note: Expansion will only occur if `isExpandable` returns `true`
     */
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
            UIView.animate(withDuration: animationDuration) {
                self.invalidateIntrinsicContentSize()
            }
        } else {
            invalidateDisplayAndLayout()
        }
        
        delegate?.readMoreLabel?(self, didChangeExpandedState: isExpanded)
        updateAccessibilityLabel()
    }
    
    /// Updates accessibility label based on current expansion state
    private func updateAccessibilityLabel() {
        if isExpanded {
            accessibilityLabel = collapseAccessibilityLabel ?? "Tap to show less"
            accessibilityHint = "Double-tap to collapse text"
        } else {
            accessibilityLabel = readMoreAccessibilityLabel ?? "Tap to read more" 
            accessibilityHint = "Double-tap to expand full text"
        }
    }
    
    /**
     Resets the label to collapsed state for table/collection view cell reuse.
     Call this method in `prepareForReuse()` to ensure consistent initial state.
     */
    @objc public func prepareForCellReuse() {
        if isExpanded {
            setExpanded(false, animated: false)
        }
    }
    
    /**
     Returns all NSRange locations of "Read More" text in the current attributed text.
     Useful for custom hit testing or accessibility implementations.
     
     - Returns: Array of NSRange objects marking "Read More" text locations
     */
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
    
    // MARK: - Performance Optimization Methods
    
    /// Invalidates the layout cache, forcing recalculation on next layout
    private func invalidateLayoutCache() {
        layoutCache = nil
    }
    
    /// Checks if the current layout cache is valid for the given parameters
    private func isLayoutCacheValid(for text: NSAttributedString, bounds: CGRect, numberOfLines: Int) -> Bool {
        return layoutCache?.isValidFor(text: text, bounds: bounds, numberOfLines: numberOfLines) ?? false
    }
    
    /// Stores the calculated layout result in cache for future reuse
    private func cacheLayoutResult(_ result: TextTruncationResult, for text: NSAttributedString, bounds: CGRect, numberOfLines: Int) {
        layoutCache = LayoutCache(
            text: NSAttributedString(attributedString: text),
            bounds: bounds,
            numberOfLines: numberOfLines,
            truncationResult: result
        )
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
    
    
    private func findTruncateLocationWithWidth(_ targetWidth: CGFloat, in glyphRange: NSRange, layoutManager: NSLayoutManager) -> Int {
        // Safety checks
        guard targetWidth > 0, 
              glyphRange.length > 0,
              !layoutManager.textContainers.isEmpty else {
            return glyphRange.location
        }
        
        let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
        
        // Ensure character range is valid
        guard characterRange.length > 0 else {
            return glyphRange.location
        }
        
        let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphRange.location, effectiveRange: nil)
        
        // Safety check for line rect validity
        guard lineRect.width > 0, lineRect.height > 0 else {
            return characterRange.location
        }
        
        let targetPoint = CGPoint(x: lineRect.origin.x + targetWidth, y: lineRect.midY)
        
        let characterIndex = layoutManager.characterIndex(
            for: targetPoint,
            in: layoutManager.textContainers[0],
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // Enhanced safety clamping
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
        // Safety checks
        guard containerWidth > 0 else {
            assertionFailure("ReadMoreLabel: Invalid container width (\(containerWidth))")
            let fallbackWidth: CGFloat = 100
            return createTextKitStack(for: attributedText, containerWidth: fallbackWidth)
        }
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: containerWidth, height: .greatestFiniteMagnitude))
        
        // Defensive setup - ensure proper connections
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        // Verify connections were established
        assert(layoutManager.textStorage === textStorage, "TextStorage connection failed")
        assert(textContainer.layoutManager === layoutManager, "LayoutManager connection failed")
        
        textContainer.lineFragmentPadding = lineFragmentPadding
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = 0
        
        // Ensure layout is computed
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
        guard attributedText.length > 0 && availableWidth > 0 && numberOfLinesWhenCollapsed > 0 else {
            super.attributedText = attributedText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed == 0 ? 0 : numberOfLinesWhenCollapsed)
            readMoreTextRange = nil
            return
        }
        
        let suffix = createReadMoreSuffix(from: attributedText)
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
    
    
    // MARK: - Optimized New Implementations (Phase 1)
    
    /// 최적화된 applyReadMore 구현 - 통합된 헬퍼 메서드 활용
    private func applyReadMore(
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
        
        // 통합된 헬퍼 메서드로 줄 수 계산
        let actualLinesNeeded = calculateLineCount(from: layoutManager, totalGlyphCount: totalGlyphCount)
        
        if actualLinesNeeded <= numberOfLines {
            return .noTruncationNeeded
        }

        // 통합된 헬퍼 메서드로 타겟 라인 찾기
        guard let lastLineRange = findTargetLineRange(from: layoutManager, totalGlyphCount: totalGlyphCount, targetLine: numberOfLines) else {
            return .noTruncationNeeded
        }
        
        // 정확한 너비 계산 - lineFragmentUsedRect 사용
        let lastLineUsedRect = layoutManager.lineFragmentUsedRect(forGlyphAt: lastLineRange.location, effectiveRange: nil)
        let lastLineWidth = lastLineUsedRect.width
        
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
    
    /// 최적화된 applyReadMoreForNewLine 구현 - 통합된 헬퍼 메서드 활용
    private func applyReadMoreForNewLine(
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
        
        // 통합된 헬퍼 메서드로 줄 수 계산
        let actualLinesNeeded = calculateLineCount(from: layoutManager, totalGlyphCount: totalGlyphCount)
        
        if actualLinesNeeded <= numberOfLines {
            return .noTruncationNeeded
        }
        
        // 통합된 헬퍼 메서드로 타겟 라인 찾기
        guard let lastLineRange = findTargetLineRange(from: layoutManager, totalGlyphCount: totalGlyphCount, targetLine: numberOfLines) else {
            return .noTruncationNeeded
        }
        
        let characterRange = layoutManager.characterRange(forGlyphRange: lastLineRange, actualGlyphRange: nil)
        
        // 더보기 텍스트 생성
        let lastAttributes = originalText.lastTextAttributes(defaultAttributes: defaultTextAttributes)
        let readMoreWithOriginalAttributes = readMoreText.createMutableWithAttributes(lastAttributes)
        
        // newLine position에서는 현재 줄에서 "더보기" 공간을 확보할 필요 없음
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
    
    /// 최적화된 실제 필요 라인 수 계산 - 통합된 헬퍼 메서드 활용
    private func calculateActualLinesNeeded(for text: NSAttributedString, width: CGFloat) -> Int {
        let alignedText = applyTextAlignment(to: text)
        let (textStorage, layoutManager, textContainer) = createTextKitStack(for: alignedText, containerWidth: width)
        
        let totalGlyphCount = layoutManager.numberOfGlyphs
        guard totalGlyphCount > 0 else { return 0 }
        
        // 통합된 헬퍼 메서드 활용
        return calculateLineCount(from: layoutManager, totalGlyphCount: totalGlyphCount)
    }
    
    /// 최적화된 텍스트 크기 계산
    private func calculateTextSize(for text: NSAttributedString, width: CGFloat) -> CGSize {
        let alignedText = applyTextAlignment(to: text)
        let (textStorage, layoutManager, textContainer) = createTextKitStack(for: alignedText, containerWidth: width)
        
        let usedRect = layoutManager.usedRect(for: textContainer)
        return usedRect.size
    }
    
    // MARK: - 최적화된 TextKit 헬퍼 메서드
    
    /// 공통 줄 수 계산 로직 - 모든 enumeration 처리를 통합
    private func calculateLineCount(
        from layoutManager: NSLayoutManager,
        totalGlyphCount: Int
    ) -> Int {
        guard totalGlyphCount > 0 else { return 0 }
        
        var lineCount = 0
        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: totalGlyphCount)) { 
            (rect, _, _, _, _) in
            if rect.height > 0 { 
                lineCount += 1 
            }
        }
        
        // 마지막 줄 높이 0 검사
        if lineCount > 0 {
            let lastLineGlyphIndex = totalGlyphCount - 1
            let lastLineRect = layoutManager.lineFragmentRect(forGlyphAt: lastLineGlyphIndex, effectiveRange: nil)
            
            if lastLineRect.height == 0 {
                lineCount -= 1
            }
        }
        
        return lineCount
    }
    
    /// 공통 타겟 라인 찾기 로직 - 중복 enumeration 제거
    private func findTargetLineRange(
        from layoutManager: NSLayoutManager,
        totalGlyphCount: Int,
        targetLine: Int
    ) -> NSRange? {
        guard totalGlyphCount > 0 else { return nil }
        
        var targetLineRange = NSRange()
        var currentLineCount = 0
        
        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: totalGlyphCount)) { 
            (rect, _, _, glyphRange, stop) in
            if rect.height > 0 {
                currentLineCount += 1
                if currentLineCount == targetLine {
                    targetLineRange = glyphRange
                    stop.pointee = true
                }
            }
        }
        
        return currentLineCount >= targetLine ? targetLineRange : nil
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
        invalidateLayoutCache()
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
        let previousBounds = bounds
        super.layoutSubviews()
        
        // Invalidate cache if bounds changed significantly (width affects text layout)
        if abs(previousBounds.width - bounds.width) > 1.0 {
            invalidateLayoutCache()
        }
        
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
        // Legacy와 동일한 방식으로 TextKit 스택 생성
        let alignedText = applyTextAlignment(to: attributedText)
        let (textStorage, layoutManager, textContainer) = createTextKitStack(for: alignedText, containerWidth: containerWidth)
        
        let totalGlyphCount = layoutManager.numberOfGlyphs
        
        guard totalGlyphCount > 0 else { 
            return (0, nil) 
        }
        
        var lineFragments: [(rect: CGRect, glyphRange: NSRange)] = []
        
        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: totalGlyphCount)) { 
            (rect, _, _, glyphRange, _) in
            if rect.height > 0 {
                lineFragments.append((rect: rect, glyphRange: glyphRange))
            }
        }
        
        let targetFragment = targetLineIndex < lineFragments.count ? lineFragments[targetLineIndex] : nil
        
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
