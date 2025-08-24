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
        lineBreakMode = .byClipping
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
        invalidateExpandableCache()
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
    private func createTextKitStack(for attributedText: NSAttributedString, containerWidth: CGFloat) -> (NSTextStorage, NSLayoutManager, NSTextContainer) {
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: containerWidth, height: .greatestFiniteMagnitude))
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = lineFragmentPadding
        textContainer.lineBreakMode = .byWordWrapping
        textContainer.maximumNumberOfLines = 0
        
        layoutManager.ensureLayout(for: textContainer)
        
        return (textStorage, layoutManager, textContainer)
    }
    
    private func applyReadMore(
        originalText: NSAttributedString,
        numberOfLines: Int,
        containerWidth: CGFloat,
        suffix: NSAttributedString
    ) -> TextTruncationResult {
        
        let alignedText = applyTextAlignment(to: originalText)
        let (_, layoutManager, _) = createTextKitStack(for: alignedText, containerWidth: containerWidth)
        
        let actualLinesNeeded = calculateActualLinesNeeded(for: alignedText, width: containerWidth)
        
        if actualLinesNeeded <= numberOfLines {
            return .noTruncationNeeded
        }
        
        let totalGlyphCount = layoutManager.numberOfGlyphs
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
        let lastAttributes = getLastTextAttributes(from: originalText)
        
        let suffix = NSMutableAttributedString()
        
        suffix.append(NSAttributedString(string: ellipsisText, attributes: lastAttributes))
        suffix.append(NSAttributedString(string: " ", attributes: lastAttributes))
        let readMoreStartLocation = suffix.length
        
        let readMoreWithOriginalAttributes = NSMutableAttributedString(string: readMoreText.string, attributes: lastAttributes)
        
        readMoreText.enumerateAttributes(in: NSRange(location: 0, length: readMoreText.length), options: []) { attributes, range, _ in
            for (key, value) in attributes {
                if key != .paragraphStyle {
                    readMoreWithOriginalAttributes.addAttribute(key, value: value, range: NSRange(location: 0, length: readMoreWithOriginalAttributes.length))
                }
            }
        }
        
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
    
    private func getLastTextAttributes(from originalText: NSAttributedString) -> [NSAttributedString.Key: Any] {
        return originalText.length > 0 ?
            originalText.attributes(at: originalText.length - 1, effectiveRange: nil) :
            defaultTextAttributes
    }

    
        
    private func setInternalNumberOfLines(_ lines: Int) {
        internalNumberOfLines = lines
        super.numberOfLines = lines
    }
    
    // MARK: - TextKit Helper Methods
    
    
    private func updateDisplay() {
        guard let attributedTextToDisplay = originalAttributedText, case let availableWidth = bounds.width, availableWidth > 0 else {
            return
        }
        
        if numberOfLinesWhenCollapsed == 0 {
            super.attributedText = attributedTextToDisplay
            setInternalNumberOfLines(0)
            readMoreTextRange = nil
            invalidateIntrinsicContentSize()
            return
        }
        
        if isExpanded {
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
            let actualLinesInFinalText = calculateActualLinesNeeded(for: finalText, width: availableWidth)
            
            super.attributedText = finalText
            setInternalNumberOfLines(actualLinesInFinalText)
            readMoreTextRange = readMoreRange
            
        } else {
            super.attributedText = attributedText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed == 0 ? 0 : numberOfLinesWhenCollapsed)
            readMoreTextRange = nil
        }
    }
    
    private func applyReadMoreForNewLine(
        originalText: NSAttributedString,
        numberOfLines: Int,
        containerWidth: CGFloat
    ) -> TextTruncationResult {
        
        let alignedText = applyTextAlignment(to: originalText)
        
        let actualLinesNeeded = calculateActualLinesNeeded(for: alignedText, width: containerWidth)
        
        if actualLinesNeeded <= numberOfLines {
            return .noTruncationNeeded
        }
        
        if canFitNewLineAndSuffixWithinBounds(alignedText: alignedText, numberOfLines: numberOfLines, containerWidth: containerWidth) {
            return .noTruncationNeeded
        }
        
        let (_, layoutManager, _) = createTextKitStack(for: alignedText, containerWidth: containerWidth)
        let totalGlyphCount = layoutManager.numberOfGlyphs
        var currentLineCount = 0
        var lastLineRange = NSRange()
        
        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: totalGlyphCount)) { 
            (rect, usedRect, textContainer, glyphRange, stop) in
            currentLineCount += 1
            if currentLineCount == numberOfLines {
                lastLineRange = glyphRange
                stop.pointee = true
            }
        }
        
        let characterRange = layoutManager.characterRange(forGlyphRange: lastLineRange, actualGlyphRange: nil)
        let truncateOffset = characterRange.location + characterRange.length
        let truncatedSubstring = originalText.attributedSubstring(from: NSRange(location: 0, length: truncateOffset))
        
        let cleanedTruncatedText = removeTrailingNewlineIfNeeded(from: truncatedSubstring)
        let finalText = NSMutableAttributedString(attributedString: cleanedTruncatedText)
        
        let lastAttributes = getLastTextAttributes(from: originalText)
        finalText.append(NSAttributedString(string: "\n", attributes: lastAttributes))
        let readMoreStartLocation = finalText.length
        
        let readMoreWithOriginalAttributes = NSMutableAttributedString(string: readMoreText.string, attributes: lastAttributes)
        
        readMoreText.enumerateAttributes(in: NSRange(location: 0, length: readMoreText.length), options: []) { attributes, range, _ in
            for (key, value) in attributes {
                if key != .paragraphStyle {
                    readMoreWithOriginalAttributes.addAttribute(key, value: value, range: NSRange(location: 0, length: readMoreWithOriginalAttributes.length))
                }
            }
        }
        
        finalText.append(readMoreWithOriginalAttributes)
        let finalReadMoreRange = NSRange(location: readMoreStartLocation, length: readMoreWithOriginalAttributes.length)
        finalText.addAttribute(AttributeKey.isReadMore, value: true, range: finalReadMoreRange)
        
        return .truncated(finalText, finalReadMoreRange)
    }
    
    private func canFitNewLineAndSuffixWithinBounds(alignedText: NSAttributedString, numberOfLines: Int, containerWidth: CGFloat) -> Bool {
        let (_, layoutManager, _) = createTextKitStack(for: alignedText, containerWidth: containerWidth)
        
        let totalGlyphCount = layoutManager.numberOfGlyphs
        guard totalGlyphCount > 0 else { return true }
        
        var currentLineCount = 0
        var lastLineRange = NSRange()
        
        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: totalGlyphCount)) { 
            (rect, usedRect, textContainer, glyphRange, stop) in
            currentLineCount += 1
            if currentLineCount == numberOfLines {
                lastLineRange = glyphRange
                stop.pointee = true
            }
        }
        
        let characterRange = layoutManager.characterRange(forGlyphRange: lastLineRange, actualGlyphRange: nil)
        
        let lineStartOffset = characterRange.location
        let lineEndOffset = characterRange.location + characterRange.length
        
        let actualReadMoreText = createReadMoreSuffix(from: alignedText)
        let lastAttributes = getLastTextAttributes(from: alignedText)
        let suffixText = NSMutableAttributedString(string: "\n", attributes: lastAttributes)
        suffixText.append(actualReadMoreText)
        
        let suffixSize = suffixText.boundingRect(
            with: CGSize(width: containerWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
        let availableWidthForText = containerWidth - suffixSize.width
        
        var truncateOffset = lineEndOffset
        var currentWidth: CGFloat = 0
        
        for i in (lineStartOffset..<lineEndOffset).reversed() {
            let testText = alignedText.attributedSubstring(from: NSRange(location: lineStartOffset, length: i - lineStartOffset))
            let testSize = testText.boundingRect(
                with: CGSize(width: containerWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            ).size
            
            if testSize.width <= availableWidthForText {
                truncateOffset = i
                currentWidth = testSize.width
                break
            }
        }
        
        let truncatedText = alignedText.attributedSubstring(from: NSRange(location: 0, length: min(truncateOffset, alignedText.length)))
        
        let testText = NSMutableAttributedString(attributedString: truncatedText)
        testText.append(suffixText)
        let testLinesNeeded = calculateActualLinesNeeded(for: testText, width: containerWidth)
        
        return testLinesNeeded <= numberOfLines
    }
    
    
    private func invalidateExpandableCache() {
    }
    
    private func invalidateDisplayAndLayout() {
        invalidateExpandableCache()
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
    
    private func calculateActualLinesNeeded(for text: NSAttributedString, width: CGFloat) -> Int {
        let alignedText = applyTextAlignment(to: text)
        let (_, layoutManager, _) = createTextKitStack(for: alignedText, containerWidth: width)
        
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
    
    private func calculateTextSize(for text: NSAttributedString, width: CGFloat) -> CGSize {
        let alignedText = applyTextAlignment(to: text)
        let (_, layoutManager, textContainer) = createTextKitStack(for: alignedText, containerWidth: width)
        
        let usedRect = layoutManager.usedRect(for: textContainer)
        return usedRect.size
    }
    
    private func checkAndResetTruncationStateIfNeeded() {
        guard let originalText = originalAttributedText,
              numberOfLinesWhenCollapsed > 0,
              bounds.width > 0 else {
            return
        }
        
        let alignedText = applyTextAlignment(to: originalText)
        let actualLinesNeeded = calculateActualLinesNeeded(for: alignedText, width: bounds.width)
        
        if actualLinesNeeded <= numberOfLinesWhenCollapsed {
            readMoreTextRange = nil
            super.attributedText = originalText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed == 0 ? 0 : numberOfLinesWhenCollapsed)
            invalidateIntrinsicContentSize()
        } else {
            readMoreTextRange = nil
            super.attributedText = originalText
            switch readMorePosition {
            case .end:
                displayTruncatedTextAtEnd(originalText, availableWidth: bounds.width)
            case .newLine:
                displayTruncatedTextAtNewLineBeginning(originalText, availableWidth: bounds.width)
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if isExpanded {
            checkAndResetExpandedStateIfNeeded()
        } else {
            checkAndResetTruncationStateIfNeeded()
        }
        
        invalidateExpandableCache()
    }
    
    public override var intrinsicContentSize: CGSize {
        guard let attributedText = attributedText, attributedText.length > 0 else {
            return super.intrinsicContentSize
        }
        
        let width = bounds.width
        let size = calculateTextSizeWithNumberOfLines(for: attributedText, width: width, numberOfLines: super.numberOfLines)
        
        return CGSize(width: size.width, height: size.height)
    }
    
    private func calculateTextSizeWithNumberOfLines(for attributedText: NSAttributedString, width: CGFloat, numberOfLines: Int) -> CGSize {
        guard width > 0 else { return .zero }
        
        let (_, layoutManager, textContainer) = createTextKitStack(for: attributedText, containerWidth: width)
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
        
        let (_, layoutManager, textContainer) = createTextKitStack(for: attributedText, containerWidth: bounds.width)
        
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
