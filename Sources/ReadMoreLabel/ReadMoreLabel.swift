import UIKit

// MARK: - Public Protocols (Interface Segregation Principle)

/// Configuration interface for ReadMore appearance and behavior
public protocol ReadMoreConfiguration: AnyObject {
    var readMoreText: NSAttributedString { get set }
    var ellipsisText: NSAttributedString { get set }
    var readMorePosition: ReadMoreLabel.Position { get set }
}

/// Action interface for ReadMore expansion/collapse operations
public protocol ReadMoreActions: AnyObject {
    func expand()
    func collapse()
    func setExpanded(_ expanded: Bool)
}

/// Query interface for ReadMore text range inspection
public protocol ReadMoreQueryable: AnyObject {
    var isExpandable: Bool { get }
    var isExpanded: Bool { get set }
}

@objc public protocol ReadMoreLabelDelegate: AnyObject {
    @objc optional func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool)
}

/// UILabel with "Read More" functionality for truncated text
/// Implements segregated interfaces for better maintainability and testability
@objc @IBDesignable
public class ReadMoreLabel: UILabel, ReadMoreConfiguration, ReadMoreActions, ReadMoreQueryable {
    @objc public weak var delegate: ReadMoreLabelDelegate?

    private var state = State()

    private var numberOfLinesWhenCollapsed: Int {
        get {
            state.numberOfLines
        }
        set {
            state.updateNumberOfLines(newValue)
            invalidateDisplayAndLayout()
        }
    }

    @objc public var isExpanded: Bool {
        get {
            state.isExpanded
        }
        set {
            // Internal state update without delegate notification
            // Delegate notification is handled by setExpanded methods
            guard state.setExpanded(newValue) else {
                return
            }
            updateDisplay()
            // Note: delegate notification removed to prevent double calls
            // Use setExpanded(_:) or setExpanded(_:notifyDelegate:) for delegate notification
        }
    }

    @objc public var isExpandable: Bool {
        state.isExpandable
    }

    @objc public var readMoreText: NSAttributedString = .init(string: "Read More..") {
        didSet {
            guard readMoreText != oldValue else {
                return
            }
            handleConfigurationChange()
        }
    }

    @objc public var ellipsisText: NSAttributedString = .init(string: "..") {
        didSet {
            guard ellipsisText != oldValue else {
                return
            }
            handleConfigurationChange()
        }
    }

    @objc public var readMorePosition: Position = .end {
        didSet {
            guard readMorePosition != oldValue else {
                return
            }

            if readMorePosition == .newLine, numberOfLinesWhenCollapsed > 0 {
                setInternalNumberOfLines(numberOfLinesWhenCollapsed + 1)
            }

            handleConfigurationChange()
        }
    }

    // MARK: - Constants

    private static let defaultSpaceBetweenEllipsisAndReadMore: String = " "
    private static let newLineCharacter: String = "\n"

    // MARK: - Private Properties

    private var tapGestureRecognizer: UITapGestureRecognizer?

    private var lineFragmentPadding: CGFloat {
        0.0
    }

    /// RTL(Right-to-Left) 환경 감지
    private var isRTL: Bool {
        return semanticContentAttribute == .forceRightToLeft ||
               (semanticContentAttribute == .unspecified &&
                effectiveUserInterfaceLayoutDirection == .rightToLeft)
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
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.alignment = textAlignment
        paragraphStyle.usesDefaultHyphenation = false

        attributes[.paragraphStyle] = paragraphStyle

        return attributes
    }

    // MARK: - UILabel Overrides

    override public var bounds: CGRect {
        didSet {
            guard bounds.size != oldValue.size else {
                return
            }

            reapplyTextStylingAndRefreshDisplay()
        }
    }

    override public var numberOfLines: Int {
        get {
            numberOfLinesWhenCollapsed
        }
        set {
            numberOfLinesWhenCollapsed = newValue
        }
    }

    override public var lineBreakMode: NSLineBreakMode {
        didSet {
            guard lineBreakMode != oldValue else {
                return
            }
            reapplyTextStylingAndRefreshDisplay()
        }
    }

    override public var font: UIFont! {
        didSet {
            guard font != oldValue else {
                return
            }
            reapplyTextStylingAndRefreshDisplay()
        }
    }

    override public var textColor: UIColor! {
        didSet {
            guard textColor != oldValue else {
                return
            }
            reapplyTextStylingAndRefreshDisplay()
        }
    }

    override public var textAlignment: NSTextAlignment {
        didSet {
            guard textAlignment != oldValue else {
                return
            }
            reapplyTextStylingAndRefreshDisplay()
        }
    }

    override public var text: String? {
        didSet {
            setOriginalText(NSAttributedString(string: text ?? ""))
        }
    }

    override public var attributedText: NSAttributedString? {
        get {
            super.attributedText
        }
        set {
            setOriginalText(newValue ?? NSAttributedString())
        }
    }

    // MARK: - Initialization

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabel()
    }

    // MARK: - Public Interface

    public func expand() {
        setExpanded(true)
    }

    public func collapse() {
        setExpanded(false)
    }

    public func setExpanded(_ expanded: Bool) {
        setExpanded(expanded, notifyDelegate: false)
    }

    // MARK: - Private Implementation

    /// Set expanded state with option to control delegate notification
    /// - Parameters:
    ///   - expanded: The expanded state to set
    ///   - notifyDelegate: Whether to notify delegate of the change
    private func setExpanded(_ expanded: Bool, notifyDelegate: Bool) {
        guard expanded == false || isExpandable else {
            return
        }

        guard expanded != isExpanded else {
            return
        }

        isExpanded = expanded
        updateDisplay()
        invalidateDisplayAndLayout()

        if notifyDelegate {
            delegate?.readMoreLabel?(self, didChangeExpandedState: isExpanded)
        }
    }

    private func setupLabel() {
        setInternalNumberOfLines(safeLineCount)
        lineBreakMode = .byWordWrapping
        isUserInteractionEnabled = true
        setupTapGesture()
    }

    private func setupTapGesture() {
        // Remove existing tap gesture if any
        if let existingGesture = tapGestureRecognizer {
            removeGestureRecognizer(existingGesture)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGestureRecognizer = tapGesture
        addGestureRecognizer(tapGesture)
    }

    /// Single responsibility method for handling configuration changes
    private func handleConfigurationChange() {
        updateDisplay()
        invalidateDisplayAndLayout()
    }

    private func applyReadMore(
        originalText: NSAttributedString,
        numberOfLines: Int,
        containerWidth: CGFloat,
        suffix: NSAttributedString,
        isRTL: Bool = false
    ) -> TextTruncationResult {
        let alignedText = originalText.applyingTextAlignment(textAlignment, font: font, textColor: textColor)
        
        // TextKit 2: Handle different positions - use TextKit 2 for both .end and .newLine
        if readMorePosition == .newLine {
            // Use TextKit 2 for newLine position as requested by user
            return alignedText.applyingReadMoreForNewLineTextLayout(
                numberOfLines: numberOfLines,
                containerWidth: containerWidth,
                textAlignment: textAlignment,
                font: font,
                textColor: textColor,
                lineFragmentPadding: lineFragmentPadding,
                lineBreakMode: lineBreakMode,
                readMoreText: readMoreText,
                newLineCharacter: Self.newLineCharacter,
                attributeKey: AttributeKey.isReadMore,
                defaultAttributes: defaultTextAttributes,
                isRTL: isRTL
            )
        } else {
            // Use TextKit 2 for .end position as requested by user
            return alignedText.applyingReadMoreTruncation(
                numberOfLines: numberOfLines,
                containerWidth: containerWidth,
                suffix: suffix,
                lineFragmentPadding: lineFragmentPadding,
                lineBreakMode: lineBreakMode,
                isRTL: isRTL
            )
        }
    }

    private func setInternalNumberOfLines(_ lines: Int) {
        state.internalNumberOfLines = lines
        super.numberOfLines = lines
    }

    // MARK: - Enhanced TextKit 1 Helper Methods

    /// Helper to get safe line count for display
    private var safeLineCount: Int {
        numberOfLinesWhenCollapsed == 0 ? 0 : numberOfLinesWhenCollapsed
    }

    private func updateDisplay() {
        guard let displayState = validateDisplayState() else {
            return
        }

        if shouldDisplayExpandedText() {
            handleExpandedState(displayState.attributedText)
            return
        }

        displayTruncatedText(
            displayState.attributedText,
            availableWidth: displayState.availableWidth
        )
    }

    /// Validates and returns display state, or nil if invalid (optimized)
    private func validateDisplayState() -> (attributedText: NSAttributedString, availableWidth: CGFloat)? {
        // Performance optimization: early bounds check
        let availableWidth = bounds.width
        guard availableWidth > 0,
              let attributedTextToDisplay = state.originalText,
              attributedTextToDisplay.length > 0 else
        {
            return nil
        }

        return (attributedTextToDisplay, availableWidth)
    }

    /// Checks if text should be displayed in expanded form (optimized)
    private func shouldDisplayExpandedText() -> Bool {
        // Performance optimization: check cheaper condition first
        isExpanded || numberOfLinesWhenCollapsed == 0
    }

    /// Handles expanded text display
    private func handleExpandedState(_ attributedText: NSAttributedString) {
        super.attributedText = attributedText
        setInternalNumberOfLines(0)
        state.readMoreTextRange = nil
        invalidateIntrinsicContentSize()
    }

    /// Displays truncated text based on readMorePosition
    private func displayTruncatedText(_ attributedText: NSAttributedString, availableWidth: CGFloat) {
        switch readMorePosition {
        case .end:
            displayTruncatedTextAtEnd(attributedText, availableWidth: availableWidth)
        case .newLine:
            displayTruncatedTextAtNewLineBeginning(attributedText, availableWidth: availableWidth)
        }
    }

    private func displayTruncatedTextAtEnd(_ attributedText: NSAttributedString, availableWidth: CGFloat) {
        guard attributedText.length > 0, availableWidth > 0, numberOfLinesWhenCollapsed > 0 else {
            super.attributedText = attributedText
            setInternalNumberOfLines(safeLineCount)
            state.readMoreTextRange = nil
            return
        }

        let suffix = attributedText.creatingReadMoreSuffix(
            ellipsisText: ellipsisText,
            readMoreText: readMoreText,
            spaceBetween: Self.defaultSpaceBetweenEllipsisAndReadMore,
            attributeKey: AttributeKey.isReadMore,
            defaultAttributes: defaultTextAttributes,
            isRTL: self.isRTL
        )

        let result = applyReadMore(
            originalText: attributedText,
            numberOfLines: numberOfLinesWhenCollapsed,
            containerWidth: availableWidth,
            suffix: suffix,
            isRTL: self.isRTL
        )

        if result.needsTruncation,
           let (finalText, readMoreRange) = result.textAndRange
        {
            super.attributedText = finalText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed)
            state.readMoreTextRange = readMoreRange
        } else {
            super.attributedText = attributedText
            setInternalNumberOfLines(safeLineCount)
            state.readMoreTextRange = nil
        }
    }

    private func displayTruncatedTextAtNewLineBeginning(_ attributedText: NSAttributedString, availableWidth: CGFloat) {
        guard attributedText.length > 0, availableWidth > 0, numberOfLinesWhenCollapsed > 0 else {
            super.attributedText = attributedText
            setInternalNumberOfLines(safeLineCount)
            state.readMoreTextRange = nil
            return
        }

        let result = attributedText.applyingReadMoreForNewLineTextLayout(
            numberOfLines: numberOfLinesWhenCollapsed,
            containerWidth: availableWidth,
            textAlignment: textAlignment,
            font: font,
            textColor: textColor,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode,
            readMoreText: readMoreText,
            newLineCharacter: Self.newLineCharacter,
            attributeKey: AttributeKey.isReadMore,
            defaultAttributes: defaultTextAttributes,
            isRTL: self.isRTL
        )

        if result.needsTruncation,
           let (finalText, readMoreRange) = result.textAndRange
        {
        
            // Always show numberOfLines + 1 lines in newLine position
            super.attributedText = finalText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed + 1)
            state.readMoreTextRange = readMoreRange
        } else {
            super.attributedText = attributedText
            setInternalNumberOfLines(safeLineCount)
            state.readMoreTextRange = nil
        }
    }

    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard isExpandable, !isExpanded, let attributedText else {
            return
        }

        let locationInLabel = gesture.location(in: self)

        guard attributedText.length > 0, bounds.width > 0 else {
            return
        }

        if hasReadMoreTextAtLocation(locationInLabel, in: attributedText) {
            // Notify delegate about user-initiated expansion
            setExpanded(true, notifyDelegate: true)
        }
    }

    private func invalidateDisplayAndLayout() {
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    /// Reapplies current text styling (alignment, font, color) and refreshes display
    private func reapplyTextStylingAndRefreshDisplay() {
        if let originalText = state.originalText {
            state.updateOriginalText(originalText.applyingTextAlignment(
                textAlignment,
                font: font,
                textColor: textColor
            ))
        }

        updateDisplay()
        invalidateDisplayAndLayout()
    }

    private func setOriginalText(_ text: NSAttributedString) {
        state.updateOriginalText(text.applyingTextAlignment(
            textAlignment,
            font: font,
            textColor: textColor
        ))

        updateDisplay()
        invalidateDisplayAndLayout()
    }

    private func hasReadMoreTextAtLocation(_ location: CGPoint, in attributedText: NSAttributedString) -> Bool {
        guard attributedText.length > 0, let readMoreRange = state.readMoreTextRange else {
            return false
        }
        
        // TextKit 2: Use as requested by user - fix coordinate system compatibility
        let result = attributedText.hitTestReadMoreTextLayout(
            at: location,
            in: readMoreRange,
            containerWidth: bounds.width,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode,
            readMorePosition: readMorePosition,
            newLineCharacter: Self.newLineCharacter,
            isRTL: self.isRTL
        )
        
        return result
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
            attributes(at: length - 1, effectiveRange: nil)
        } else {
            defaultAttributes
        }
    }

    /// Enhanced TextKit 2: Modern width calculation using NSTextLayoutFragment
    /// - Parameters:
    ///   - containerWidth: Width constraint for the text container
    ///   - lineFragmentPadding: Line fragment padding (default: 0)
    ///   - lineBreakMode: Line break mode (default: .byWordWrapping)
    /// - Returns: Calculated width of the text
    @available(iOS 16.0, *)
    func calculateTextLayoutWidth(
        with containerWidth: CGFloat,
        lineFragmentPadding: CGFloat = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping
    ) -> CGFloat {
        // Create TextKit 2 stack using unified builder for reliable width measurement
        let (textContentStorage, textLayoutManager, textContainer) = creatingTextLayoutManagerStack(
            containerWidth: containerWidth,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode
        )

        // TextKit 2: Calculate width by enumerating layout fragments
        var maxWidth: CGFloat = 0
        let documentRange = textLayoutManager.documentRange
        
        textLayoutManager.enumerateTextLayoutFragments(from: documentRange.location, options: []) { fragment in
            let fragmentWidth = fragment.layoutFragmentFrame.width
            maxWidth = max(maxWidth, fragmentWidth)
            return true // Continue enumeration
        }

        return ceil(maxWidth)
    }

    /// Removes trailing newline character if present
    func removingTrailingNewlineIfNeeded() -> NSAttributedString {
        let mutableString = NSMutableAttributedString(attributedString: self)
        if mutableString.string.hasSuffix("\n") {
            let newLength = mutableString.length - 1
            mutableString.deleteCharacters(in: NSRange(location: newLength, length: 1))
        }
        return mutableString
    }

    /// Applies text alignment and font to attributed string
    func applyingTextAlignment(_ textAlignment: NSTextAlignment, font: UIFont,
                               textColor: UIColor? = nil) -> NSAttributedString
    {
        let range = NSRange(location: 0, length: length)
        let mutableAttributedText = NSMutableAttributedString(attributedString: self)
        mutableAttributedText.addAttribute(.font, value: font, range: range)

        // Apply text color if provided
        if let textColor {
            mutableAttributedText.addAttribute(.foregroundColor, value: textColor, range: range)
        }

        // Check if alignment is already correct
        if let existingStyle = attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle,
           existingStyle.alignment == textAlignment
        {
            return mutableAttributedText
        }

        // Create or modify paragraph style
        let paragraphStyle: NSMutableParagraphStyle = if let existingStyle = attribute(
            .paragraphStyle,
            at: 0,
            effectiveRange: nil
        ) as? NSParagraphStyle {
            (existingStyle.mutableCopy() as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
        } else {
            NSMutableParagraphStyle()
        }

        paragraphStyle.alignment = textAlignment
        mutableAttributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)

        return mutableAttributedText
    }

    /// TextKit 2 precise Hit Testing: Touch detection based on glyph area
    /// Accurate touch detection using actual glyph area instead of characterIndex
    /// - Parameters:
    ///   - location: Touch point
    ///   - range: ReadMore text range
    ///   - containerWidth: Container width
    ///   - lineFragmentPadding: Line fragment padding
    ///   - lineBreakMode: Line break mode
    ///   - readMorePosition: Position type (.end or .newLine)
    ///   - newLineCharacter: New line character
    /// - Returns: Whether the touch hit the actual glyph area of ReadMore text
    @available(iOS 16.0, *)
    func hitTestReadMoreTextLayout(
        at location: CGPoint,
        in range: NSRange,
        containerWidth: CGFloat,
        lineFragmentPadding: CGFloat,
        lineBreakMode: NSLineBreakMode,
        readMorePosition: ReadMoreLabel.Position,
        newLineCharacter: String,
        isRTL: Bool
    ) -> Bool {
        let (textContentStorage, textLayoutManager, textContainer) = creatingTextLayoutManagerStack(
            containerWidth: containerWidth,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode
        )

        // Force layout - essential for accurate glyph position calculation
        textLayoutManager.ensureLayout(for: textLayoutManager.documentRange)
        
        // Standard .end position handling
        return isLocationInReadMoreGlyphBounds(
            location: location,
            range: range,
            textLayoutManager: textLayoutManager
        )
    }
    
    /// Direct ReadMore touch detection based on touch point
    @available(iOS 16.0, *)
    private func isLocationInReadMoreGlyphBounds(
        location: CGPoint,
        range: NSRange,
        textLayoutManager: NSTextLayoutManager
    ) -> Bool {
        // Get textLayoutFragment directly from touch point
        guard let fragment = textLayoutManager.textLayoutFragment(for: location) else {
            return false
        }
        
        let fragmentFrame = fragment.layoutFragmentFrame
        
        // Find character index of touch point within fragment
        for lineFragment in fragment.textLineFragments {
            let lineBounds = CGRect(
                x: fragmentFrame.origin.x + lineFragment.typographicBounds.origin.x,
                y: fragmentFrame.origin.y + lineFragment.typographicBounds.origin.y,
                width: lineFragment.typographicBounds.width,
                height: lineFragment.typographicBounds.height
            )
            
            if lineBounds.contains(location) {
                // Get character index directly from touch point
                let relativeLocation = CGPoint(
                    x: location.x - fragmentFrame.origin.x,
                    y: location.y - fragmentFrame.origin.y
                )
                
                let characterIndex = lineFragment.characterIndex(for: relativeLocation)
                
                // Calculate absolute index based on entire document
                let documentRange = textLayoutManager.documentRange
                let fragmentStartOffset = textLayoutManager.offset(from: documentRange.location, to: fragment.rangeInElement.location)
                let absoluteIndex = fragmentStartOffset + characterIndex
                
                // Check if within ReadMore range and has ReadMore attribute
                if NSLocationInRange(absoluteIndex, range) && absoluteIndex < length {
                    let attributes = attributes(at: absoluteIndex, effectiveRange: nil)
                    return (attributes[ReadMoreLabel.AttributeKey.isReadMore] as? Bool) == true
                }
            }
        }
        
        return false
    }
    
    /// Creates a ReadMore suffix with ellipsis and ReadMore text
    /// - Parameters:
    ///   - ellipsisText: Ellipsis text to prepend
    ///   - readMoreText: ReadMore text to append
    ///   - spaceBetween: Space character between ellipsis and ReadMore
    ///   - attributeKey: Attribute key for ReadMore identification
    ///   - defaultAttributes: Default text attributes to use
    /// - Returns: Complete ReadMore suffix with proper attributes
    func creatingReadMoreSuffix(
        ellipsisText: NSAttributedString,
        readMoreText: NSAttributedString,
        spaceBetween: String,
        attributeKey: NSAttributedString.Key,
        defaultAttributes: [NSAttributedString.Key: Any],
        isRTL: Bool
    ) -> NSAttributedString {
        let lastAttributes = lastTextAttributes(defaultAttributes: defaultAttributes)

        let suffix = NSMutableAttributedString()
        let ellipsisWithLastAttributes = ellipsisText.createMutableWithAttributes(lastAttributes)

        // RTL/LTR에 따른 구성 요소 순서 및 간격 처리
        suffix.append(ellipsisWithLastAttributes) // ".."
        suffix.append(NSAttributedString(string: isRTL ? "\u{00A0}" : spaceBetween, attributes: lastAttributes)) // NBSP
        
        // readMore 텍스트 처리 (공통 로직)
        let readMoreStartLocation = suffix.length
        let readMoreWithOriginalAttributes = readMoreText.createMutableWithAttributes(lastAttributes)
        
        // RTL에서만 BiDi 중립 문자 처리를 위한 RLM 추가
        if isRTL {
            readMoreWithOriginalAttributes.append(NSAttributedString(string: "\u{200F}", attributes: lastAttributes)) // RLM
        }
        
        suffix.append(readMoreWithOriginalAttributes)
        
        // readMore 범위 설정 (RTL은 원본 길이, LTR은 실제 길이 사용)
        let readMoreRange = NSRange(
            location: readMoreStartLocation, 
            length: isRTL ? readMoreText.length : readMoreWithOriginalAttributes.length
        )
        suffix.addAttribute(attributeKey, value: true, range: readMoreRange)

        return suffix
    }

    /// Enhanced TextKit 2: Modern text truncation with NSTextLayoutFragment
    /// Uses enumerateTextLayoutFragments for precise line fragment handling
    /// - Parameters:
    ///   - numberOfLines: Maximum number of lines to display
    ///   - containerWidth: Available width for text layout
    ///   - suffix: ReadMore suffix to append
    ///   - lineFragmentPadding: Line fragment padding
    ///   - lineBreakMode: Line break mode
    /// - Returns: TextTruncationResult with truncated text and range
    @available(iOS 16.0, *)
    func applyingReadMoreTruncation(
        numberOfLines: Int,
        containerWidth: CGFloat,
        suffix: NSAttributedString,
        lineFragmentPadding: CGFloat = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        isRTL: Bool = false
    ) -> ReadMoreLabel.TextTruncationResult {
        let (_, textLayoutManager, _) = creatingTextLayoutManagerStack(
            containerWidth: containerWidth,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode
        )

        // Collect all line information
        var allLineFragments: [(fragment: NSTextLayoutFragment, lineFragment: NSTextLineFragment)] = []
        textLayoutManager.enumerateTextLayoutFragments(from: textLayoutManager.documentRange.location, options: []) { fragment in
            for lineFragment in fragment.textLineFragments {
                allLineFragments.append((fragment: fragment, lineFragment: lineFragment))
            }
            return true
        }
        
        // Check line count
        guard numberOfLines < allLineFragments.count else {
            return .noTruncationNeeded
        }
        
        // Last line information
        let (lastFragment, lastLineFragment) = allLineFragments[numberOfLines - 1]
        let lastLineStart = textLayoutManager.offset(from: textLayoutManager.documentRange.location, 
                                                   to: lastFragment.rangeInElement.location) + lastLineFragment.characterRange.location
        
        // Step 1: All text before the last line
        let result = NSMutableAttributedString(attributedString: attributedSubstring(from: NSRange(location: 0, length: lastLineStart)))
        
        // Step 2: Truncate last line and add suffix
        let lastLineRange = NSRange(location: lastLineStart, length: lastLineFragment.characterRange.length)
        let lastLineText = attributedSubstring(from: lastLineRange)
        
        
        let suffixWidth = suffix.calculateTextLayoutWidth(
            with: containerWidth,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode
        )
        
        // Reserve appropriate space for suffix
        let lastLineUsedWidth = lastLineFragment.typographicBounds.width
        let maxAvailableWidth = containerWidth - suffixWidth
        
        // RTL 텍스트에서는 truncate point가 다르게 계산되어야 함
        let truncatePoint: CGPoint
        if isRTL {
            // RTL: suffix가 텍스트 시작 부분(오른쪽)에 와야 하므로 suffixWidth만큼 떨어진 곳부터 시작
            truncatePoint = CGPoint(x: suffixWidth, y: lastLineFragment.typographicBounds.midY)
        } else {
            // LTR: suffix가 텍스트 끝 부분(오른쪽)에 와야 하므로 기존 로직 사용
            truncatePoint = CGPoint(x: maxAvailableWidth, y: lastLineFragment.typographicBounds.midY)
        }

        let rawTruncateIndex = lastLineFragment.characterIndex(for: truncatePoint)
        let truncateIndex: Int
        if result.string.contains("\n") || lastLineText.string.contains("\n") {
            truncateIndex = max(0, min(rawTruncateIndex, lastLineText.length))
        } else {
            // characterIndex(for:) returns document-based index, subtract last line start for relative index
            let relativeIndex = rawTruncateIndex - lastLineStart
            truncateIndex = max(0, min(relativeIndex, lastLineText.length))
        }
        
//        if isRTL {
//            // RTL: suffix를 먼저 추가하고 그 다음에 자른 텍스트를 추가
//            let suffixStartIndex = result.length
//            result.append(suffix)
//            
//            // RTL에서는 truncateIndex부터 끝까지의 텍스트를 추가
//            let remainingRange = NSRange(location: truncateIndex, length: lastLineText.length - truncateIndex)
//            if remainingRange.length > 0 {
//                let remainingText = lastLineText.attributedSubstring(from: remainingRange).removingTrailingNewlineIfNeeded()
//                result.append(remainingText)
//            }
//            
//            return .truncated(result, NSRange(location: suffixStartIndex, length: suffix.length))
//        } else {
            // LTR: 기존 로직 사용
            let truncated = lastLineText.attributedSubstring(from: NSRange(location: 0, length: truncateIndex)).removingTrailingNewlineIfNeeded()
            result.append(truncated)
            result.append(suffix)

            return .truncated(result, NSRange(location: result.length - suffix.length, length: suffix.length))
//        }
    }

    /// TextKit 2: Applies ReadMore truncation for newLine position with enhanced coordinate handling
    /// - Parameters:
    ///   - numberOfLines: Maximum number of lines to display
    ///   - containerWidth: Available width for text layout
    ///   - textAlignment: Text alignment
    ///   - font: Font to apply
    ///   - textColor: Text color to apply
    ///   - lineFragmentPadding: Line fragment padding
    ///   - lineBreakMode: Line break mode
    ///   - readMoreText: ReadMore text to append
    ///   - newLineCharacter: Character for new line
    ///   - attributeKey: Attribute key for ReadMore identification
    ///   - defaultAttributes: Default text attributes to use
    /// - Returns: TextTruncationResult with truncated text and range
    @available(iOS 16.0, *)
    func applyingReadMoreForNewLineTextLayout(
        numberOfLines: Int,
        containerWidth: CGFloat,
        textAlignment: NSTextAlignment,
        font: UIFont,
        textColor: UIColor?,
        lineFragmentPadding: CGFloat = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        readMoreText: NSAttributedString,
        newLineCharacter: String,
        attributeKey: NSAttributedString.Key,
        defaultAttributes: [NSAttributedString.Key: Any],
        isRTL: Bool = false
    ) -> ReadMoreLabel.TextTruncationResult {
        let alignedText = applyingTextAlignment(textAlignment, font: font, textColor: textColor)
        let (_, textLayoutManager, _) = alignedText.creatingTextLayoutManagerStack(
            containerWidth: containerWidth,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode
        )

        // Collect all line information
        var allLineFragments: [(fragment: NSTextLayoutFragment, lineFragment: NSTextLineFragment)] = []
        textLayoutManager.enumerateTextLayoutFragments(from: textLayoutManager.documentRange.location, options: []) { fragment in
            for lineFragment in fragment.textLineFragments {
                allLineFragments.append((fragment: fragment, lineFragment: lineFragment))
            }
            return true
        }

        // Check line count
        guard numberOfLines < allLineFragments.count else {
            return .noTruncationNeeded
        }

        // Last line information
        let (lastFragment, lastLineFragment) = allLineFragments[numberOfLines - 1]
        let lastLineStart = textLayoutManager.offset(from: textLayoutManager.documentRange.location, 
                                                   to: lastFragment.rangeInElement.location) + lastLineFragment.characterRange.location
        let lastLineRange = NSRange(location: lastLineStart, length: lastLineFragment.characterRange.length)
        
        // newLine position: truncate at end of last line
        let truncateOffset = lastLineRange.location + lastLineRange.length
        let truncatedSubstring = attributedSubstring(from: NSRange(location: 0, length: truncateOffset))
        let cleanedTruncatedText = truncatedSubstring.removingTrailingNewlineIfNeeded()
        
        // Compose final text
        let finalText = NSMutableAttributedString(attributedString: cleanedTruncatedText)
        let lastAttributes = lastTextAttributes(defaultAttributes: defaultAttributes)
        let readMoreWithOriginalAttributes = readMoreText.createMutableWithAttributes(lastAttributes)
        
        finalText.append(NSAttributedString(string: newLineCharacter, attributes: lastAttributes))
        let readMoreStartLocation = finalText.length
        finalText.append(readMoreWithOriginalAttributes)

        let finalReadMoreRange = NSRange(location: readMoreStartLocation, length: readMoreWithOriginalAttributes.length)
        finalText.addAttribute(attributeKey, value: true, range: finalReadMoreRange)
        return .truncated(finalText, finalReadMoreRange)
    }

    /// Creates a configured TextKit 2 stack for text measurement and layout
    /// - Parameters:
    ///   - containerWidth: Width constraint for the text container
    ///   - lineFragmentPadding: Line fragment padding (default: 0)
    ///   - lineBreakMode: Line break mode (default: .byWordWrapping)
    ///   - maximumNumberOfLines: Maximum number of lines (default: 0 for unlimited)
    /// - Returns: Tuple containing connected TextKit 2 components
    @available(iOS 16.0, *)
    func creatingTextLayoutManagerStack(
        containerWidth: CGFloat,
        lineFragmentPadding: CGFloat = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        maximumNumberOfLines: Int = 0
    ) -> (textContentStorage: NSTextContentStorage, textLayoutManager: NSTextLayoutManager, textContainer: NSTextContainer) {
        // Create TextKit 2 components
        let textContentStorage = NSTextContentStorage()
        let textLayoutManager = NSTextLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: containerWidth, height: .greatestFiniteMagnitude))

        // Set up the attributed string
        textContentStorage.attributedString = NSAttributedString(attributedString: self)

        // Connect TextKit 2 components
        textContentStorage.addTextLayoutManager(textLayoutManager)
        textLayoutManager.textContainer = textContainer

        // Configure text container for TextKit 2
        textContainer.lineFragmentPadding = lineFragmentPadding
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = maximumNumberOfLines
        textContainer.widthTracksTextView = false
        textContainer.heightTracksTextView = false

        // TextKit 2: Force complete invalidation and fresh calculation
        let documentRange = textLayoutManager.documentRange
        textLayoutManager.invalidateLayout(for: documentRange)
        
        // Clear any existing layout fragments to ensure consistent calculation
        // This prevents TextKit 2 from giving inconsistent line counts
        textLayoutManager.ensureLayout(for: documentRange)

        return (textContentStorage, textLayoutManager, textContainer)
    }
}

// MARK: - ReadMoreLabel Nested Types

extension ReadMoreLabel {
    // MARK: - Public Types

    @objc public enum Position: Int {
        case end = 0
        case newLine = 1
    }

    public enum AttributeKey {
        public static let isReadMore = NSAttributedString.Key("ReadMoreLabel.isReadMore")
    }

    // MARK: - Private Structs

    /// Text content and layout state management
    private struct TextContentState {
        private(set) var originalText: NSAttributedString?
        private(set) var readMoreTextRange: NSRange?

        /// Updates original text and clears related state
        mutating func updateOriginalText(_ newText: NSAttributedString?) {
            // Performance optimization: avoid unnecessary changes
            guard originalText != newText else {
                return
            }

            originalText = newText
            readMoreTextRange = nil
        }

        /// Updates ReadMore text range
        mutating func updateReadMoreTextRange(_ range: NSRange?) {
            readMoreTextRange = range
        }

        /// Checks if content is expandable
        var isExpandable: Bool {
            guard let range = readMoreTextRange else {
                return false
            }
            return range.length > 0
        }
    }

    /// Layout configuration state management
    private struct LayoutConfigState {
        private(set) var numberOfLines: Int = 3
        private(set) var internalNumberOfLines: Int = 0

        /// Updates number of lines with validation
        mutating func updateNumberOfLines(_ newValue: Int) {
            let sanitizedValue = max(0, newValue)
            guard sanitizedValue != numberOfLines else {
                return
            }

            numberOfLines = sanitizedValue
        }

        /// Updates internal number of lines
        mutating func updateInternalNumberOfLines(_ lines: Int) {
            internalNumberOfLines = lines
        }
    }

    /// Composite state management object for ReadMoreLabel
    private struct State {
        private(set) var isExpanded: Bool = false
        private var textContentState = TextContentState()
        private var layoutConfigState = LayoutConfigState()

        // MARK: - Computed Properties

        var numberOfLines: Int { layoutConfigState.numberOfLines }

        var originalText: NSAttributedString? { textContentState.originalText }

        var readMoreTextRange: NSRange? {
            get { textContentState.readMoreTextRange }
            set { textContentState.updateReadMoreTextRange(newValue) }
        }

        var internalNumberOfLines: Int {
            get { layoutConfigState.internalNumberOfLines }
            set { layoutConfigState.updateInternalNumberOfLines(newValue) }
        }

        var isExpandable: Bool {
            guard numberOfLines > 0 else {
                return false
            }
            return textContentState.isExpandable
        }

        // MARK: - Mutating Methods

        /// Updates the number of lines
        mutating func updateNumberOfLines(_ newValue: Int) {
            layoutConfigState.updateNumberOfLines(newValue)
        }

        /// Updates the original text and resets related state
        mutating func updateOriginalText(_ newText: NSAttributedString?) {
            textContentState.updateOriginalText(newText)

            // Reset expansion state if no text
            if newText == nil, isExpanded {
                isExpanded = false
            }
        }

        /// Sets the expansion state with validation
        mutating func setExpanded(_ expanded: Bool) -> Bool {
            guard expanded != isExpanded else {
                return false
            }
            guard !expanded || isExpandable else {
                return false
            }
            isExpanded = expanded
            return true
        }
    }

    // MARK: - Internal Enums

    enum TextTruncationResult {
        case noTruncationNeeded
        case truncated(NSAttributedString, NSRange)

        var needsTruncation: Bool {
            switch self {
            case .noTruncationNeeded:
                false
            case .truncated:
                true
            }
        }

        var textAndRange: (NSAttributedString, NSRange?)? {
            switch self {
            case .noTruncationNeeded:
                nil
            case let .truncated(text, range):
                (text, range)
            }
        }
    }
}

// MARK: - String Helper Extensions

extension String {
    /// Extracts substring from NSRange for debugging purposes
    func substring(with range: NSRange) -> String? {
        guard range.location != NSNotFound,
              range.location >= 0,
              range.location + range.length <= count else {
            return nil
        }
        
        let startIndex = index(startIndex, offsetBy: range.location)
        let endIndex = index(startIndex, offsetBy: range.length)
        return String(self[startIndex..<endIndex])
    }
}
