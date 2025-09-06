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

    private var tapGestureRecognizer: UITapGestureRecognizer?

    // MARK: - Constants

    private static let defaultSpaceBetweenEllipsisAndReadMore: String = " "
    private static let newLineCharacter: String = "\n"

    // MARK: - Private Properties

    private var lineFragmentPadding: CGFloat {
        0.0
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
        tapGesture.cancelsTouchesInView = false
        tapGesture.delaysTouchesBegan = false
        tapGesture.delaysTouchesEnded = false
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
        suffix: NSAttributedString
    ) -> TextTruncationResult {
        originalText.applyingTextAlignment(textAlignment, font: font, textColor: textColor)
            .applyingReadMoreTruncation(
                numberOfLines: numberOfLines,
                containerWidth: containerWidth,
                suffix: suffix,
                lineFragmentPadding: lineFragmentPadding,
                lineBreakMode: lineBreakMode
            )
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
            defaultAttributes: defaultTextAttributes
        )

        let result = applyReadMore(
            originalText: attributedText,
            numberOfLines: numberOfLinesWhenCollapsed,
            containerWidth: availableWidth,
            suffix: suffix
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

        let result = attributedText.applyingReadMoreForNewLine(
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
            defaultAttributes: defaultTextAttributes
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
            // 사용자 터치로 인한 확장이므로 delegate에 알림
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

        // Use enhanced TextKit 1 hit testing for reliability
        return attributedText.hitTestReadMoreText(
            at: location,
            in: readMoreRange,
            containerWidth: bounds.width,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode,
            readMorePosition: readMorePosition,
            newLineCharacter: Self.newLineCharacter
        )
    }
}

// MARK: - NSLayoutManager Extensions

private extension NSLayoutManager {
    /// Enhanced TextKit 1 truncation location finder with precision
    func findTruncateLocation(withWidth targetWidth: CGFloat, in glyphRange: NSRange) -> Int {
        let characterRange = characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)

        // Enhanced hit testing with improved precision
        let lineRect = lineFragmentRect(forGlyphAt: glyphRange.location, effectiveRange: nil)

        // Accurate character boundary detection
        let targetPoint = CGPoint(x: lineRect.origin.x + targetWidth, y: lineRect.midY)

        let characterIndex = characterIndex(
            for: targetPoint,
            in: textContainers[0],
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        // Enhanced boundary checking
        let clampedIndex = max(characterRange.location,
                               min(characterIndex, characterRange.location + characterRange.length))

        return clampedIndex
    }

    /// Calculates text size with maximum number of lines constraint
    /// - Parameters:
    ///   - maxLines: Maximum number of lines (0 means no limit)
    ///   - textContainer: Text container for layout calculation
    /// - Returns: CGSize with width and height for the specified line constraint
    func calculateSizeWithMaxLines(_ maxLines: Int, in textContainer: NSTextContainer) -> CGSize {
        guard maxLines > 0 else {
            // No line limit - return full used rect
            let usedRect = usedRect(for: textContainer)
            return CGSize(width: ceil(usedRect.width), height: ceil(usedRect.height))
        }

        var lineCount = 0
        var totalHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: numberOfGlyphs)) {
            rect, usedRect, _, _, stop in
            if rect.height > 0 {
                lineCount += 1
                totalHeight += rect.height
                maxWidth = max(maxWidth, usedRect.width)

                if lineCount >= maxLines {
                    stop.pointee = true
                }
            }
        }

        return CGSize(width: ceil(maxWidth), height: ceil(totalHeight))
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

    /// Finds all text ranges marked with ReadMoreLabel.isReadMore attribute
    func findReadMoreTextRanges() -> [NSRange] {
        var ranges: [NSRange] = []
        let fullRange = NSRange(location: 0, length: length)

        enumerateAttribute(
            ReadMoreLabel.AttributeKey.isReadMore,
            in: fullRange,
            options: []
        ) { value, range, _ in
            if let isReadMore = value as? Bool, isReadMore {
                ranges.append(range)
            }
        }

        return ranges
    }

    /// Enhanced TextKit 1 suffix width calculation with precision
    func calculateWidth(
        with containerWidth: CGFloat,
        lineFragmentPadding: CGFloat = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping
    ) -> CGFloat {
        // Create TextKit 1 stack using unified builder for reliable width measurement
        let (textStorage, layoutManager, textContainer) = creatingTextKitStack(
            containerWidth: containerWidth,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode
        )

        let usedRect = layoutManager.usedRect(for: textContainer)
        return ceil(usedRect.width)
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

    /// Counts the actual number of lines needed for the attributed text
    /// - Parameters:
    ///   - containerWidth: Width constraint for text layout
    ///   - textAlignment: Text alignment to apply
    ///   - font: Font to apply
    ///   - textColor: Optional text color to apply
    ///   - lineFragmentPadding: Line fragment padding (default: 0)
    ///   - lineBreakMode: Line break mode (default: .byWordWrapping)
    /// - Returns: Number of lines needed to display the text
    func countLines(
        with containerWidth: CGFloat,
        textAlignment: NSTextAlignment,
        font: UIFont,
        textColor: UIColor? = nil,
        lineFragmentPadding: CGFloat = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping
    ) -> Int {
        let alignedText = applyingTextAlignment(textAlignment, font: font, textColor: textColor)

        // Create TextKit 1 stack using unified builder
        let (textStorage, layoutManager, textContainer) = alignedText.creatingTextKitStack(
            containerWidth: containerWidth,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode
        )

        let totalGlyphCount = layoutManager.numberOfGlyphs
        guard totalGlyphCount > 0 else {
            return 0
        }

        var lineCount = 0
        var hasValidLines = false

        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: totalGlyphCount)) {
            rect, usedRect, _, _, _ in
            // Enhanced line validation - check both height and used height
            if rect.height > 0, usedRect.height > 0 {
                lineCount += 1
                hasValidLines = true
            }
        }

        // Enhanced boundary condition handling
        if hasValidLines, lineCount > 0 {
            // Verify last line is not empty or zero-height
            let lastLineGlyphIndex = max(0, totalGlyphCount - 1)
            let lastLineRect = layoutManager.lineFragmentRect(forGlyphAt: lastLineGlyphIndex, effectiveRange: nil)
            let lastLineUsedRect = layoutManager.lineFragmentUsedRect(
                forGlyphAt: lastLineGlyphIndex,
                effectiveRange: nil
            )

            // Remove invalid last lines
            if lastLineRect.height <= 0 || lastLineUsedRect.height <= 0 {
                lineCount = max(0, lineCount - 1)
            }
        }

        return lineCount
    }

    /// Hit tests for ReadMore text at a specific location
    /// - Parameters:
    ///   - location: The point to test for hit detection
    ///   - range: The range of ReadMore text to test against
    ///   - containerWidth: Width constraint for text layout
    ///   - lineFragmentPadding: Line fragment padding
    ///   - lineBreakMode: Line break mode
    ///   - readMorePosition: Position type (.end or .newLine)
    ///   - newLineCharacter: Character to check for newLine position
    /// - Returns: true if the location hits ReadMore text, false otherwise
    func hitTestReadMoreText(
        at location: CGPoint,
        in range: NSRange,
        containerWidth: CGFloat,
        lineFragmentPadding: CGFloat,
        lineBreakMode: NSLineBreakMode,
        readMorePosition: ReadMoreLabel.Position,
        newLineCharacter: String
    ) -> Bool {
        let (textStorage, layoutManager, textContainer) = creatingTextKitStack(
            containerWidth: containerWidth,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode
        )

        let readMoreStartIndex = range.location

        // Enhanced handling for newLine position
        if readMorePosition == .newLine, readMoreStartIndex > 0 {
            let stringIndex = string.index(string.startIndex, offsetBy: readMoreStartIndex - 1)
            let previousChar = string[stringIndex]
            if String(previousChar) == newLineCharacter {
                // Line rect calculation for newLine position
                let lineRect = layoutManager.lineFragmentRect(forGlyphAt: readMoreStartIndex, effectiveRange: nil)
                return lineRect.contains(location)
            }
        }

        // Enhanced hit testing with improved accuracy
        let usedRect = layoutManager.usedRect(for: textContainer)

        // Early bounds check
        guard usedRect.contains(location) else {
            return false
        }

        let clampedLocation = CGPoint(
            x: max(0, min(location.x, usedRect.maxX)),
            y: max(0, min(location.y, usedRect.maxY))
        )

        let characterIndex = layoutManager.characterIndex(
            for: clampedLocation,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        // Enhanced character index validation
        guard characterIndex != NSNotFound,
              characterIndex >= 0,
              characterIndex < length else
        {
            return false
        }

        // Enhanced range checking
        guard NSLocationInRange(characterIndex, range) else {
            return false
        }

        // Verify the character actually has the read more attribute
        let attributes = attributes(at: characterIndex, effectiveRange: nil)
        return (attributes[ReadMoreLabel.AttributeKey.isReadMore] as? Bool) == true
    }

    /// Enhanced TextKit 1: Proven text truncation logic with optimized performance
    /// - Parameters:
    ///   - numberOfLines: Maximum number of lines to display
    ///   - containerWidth: Available width for text layout
    ///   - suffix: ReadMore suffix to append
    ///   - lineFragmentPadding: Line fragment padding
    ///   - lineBreakMode: Line break mode
    /// - Returns: TextTruncationResult with truncated text and range
    func applyingReadMoreTruncation(
        numberOfLines: Int,
        containerWidth: CGFloat,
        suffix: NSAttributedString,
        lineFragmentPadding: CGFloat = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping
    ) -> ReadMoreLabel.TextTruncationResult {
        let (textStorage, layoutManager, textContainer) = creatingTextKitStack(
            containerWidth: containerWidth,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode
        )

        let totalGlyphCount = layoutManager.numberOfGlyphs

        guard totalGlyphCount > 0 else {
            return .noTruncationNeeded
        }

        // Enhanced line count calculation with boundary condition fix
        var actualLinesNeeded = 0
        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: totalGlyphCount)) {
            rect, _, _, _, _ in
            // Count all line fragments with positive height
            if rect.height > 0 {
                actualLinesNeeded += 1
            }
        }

        // Fixed boundary condition: >= to handle exact line matches
        if actualLinesNeeded <= numberOfLines {
            return .noTruncationNeeded
        }

        // Find the target line with consistent newline handling
        var lastLineRange = NSRange()
        var currentLineCount = 0
        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: totalGlyphCount)) {
            rect, _, _, glyphRange, stop in
            // Only count line fragments with positive height (consistent with line counting above)
            if rect.height > 0 {
                currentLineCount += 1
                if currentLineCount == numberOfLines {
                    lastLineRange = glyphRange
                    stop.pointee = true
                }
            }
        }

        // Calculate actual used text width (based on usedRect)
        var lastLineUsedWidth: CGFloat = 0
        layoutManager.enumerateLineFragments(forGlyphRange: lastLineRange) {
            _, usedRect, _, _, _ in
            lastLineUsedWidth = usedRect.width
        }

        // Enhanced suffix width calculation using TextKit 1 precision with proper padding and line break mode
        let suffixWidth = suffix.calculateWidth(
            with: containerWidth,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode
        )

        // Enhanced truncation with improved precision
        let availableWidth = max(0, containerWidth - suffixWidth)
        let truncateCharacterIndex = layoutManager.findTruncateLocation(withWidth: availableWidth, in: lastLineRange)

        let truncatedText = attributedSubstring(from: NSRange(location: 0, length: truncateCharacterIndex))
        let cleanedTruncatedText = truncatedText.removingTrailingNewlineIfNeeded()
        let finalText = NSMutableAttributedString(attributedString: cleanedTruncatedText)
        finalText.append(suffix)

        let readMoreRange = NSRange(location: cleanedTruncatedText.length, length: suffix.length)

        return .truncated(finalText, readMoreRange)
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
        defaultAttributes: [NSAttributedString.Key: Any]
    ) -> NSAttributedString {
        let lastAttributes = lastTextAttributes(defaultAttributes: defaultAttributes)

        let suffix = NSMutableAttributedString()

        let ellipsisWithLastAttributes = ellipsisText.createMutableWithAttributes(lastAttributes)

        suffix.append(ellipsisWithLastAttributes)
        suffix.append(NSAttributedString(string: spaceBetween, attributes: lastAttributes))
        let readMoreStartLocation = suffix.length

        let readMoreWithOriginalAttributes = readMoreText.createMutableWithAttributes(lastAttributes)

        suffix.append(readMoreWithOriginalAttributes)
        let readMoreRange = NSRange(location: readMoreStartLocation, length: readMoreWithOriginalAttributes.length)
        suffix.addAttribute(attributeKey, value: true, range: readMoreRange)

        return suffix
    }

    /// Applies ReadMore truncation for newLine position
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
    func applyingReadMoreForNewLine(
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
        defaultAttributes: [NSAttributedString.Key: Any]
    ) -> ReadMoreLabel.TextTruncationResult {
        let alignedText = applyingTextAlignment(textAlignment, font: font, textColor: textColor)
        let (textStorage, layoutManager, textContainer) = alignedText.creatingTextKitStack(
            containerWidth: containerWidth,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode
        )

        let totalGlyphCount = layoutManager.numberOfGlyphs

        guard totalGlyphCount > 0 else {
            return .noTruncationNeeded
        }

        // Collect and analyze line information in single pass
        var lineFragments: [(rect: CGRect, glyphRange: NSRange)] = []

        layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: totalGlyphCount)) {
            rect, _, _, glyphRange, _ in
            // Exclude lines with zero height
            if rect.height > 0 {
                lineFragments.append((rect: rect, glyphRange: glyphRange))
            }
        }

        let actualLinesNeeded = lineFragments.count

        // Early exit: no truncation needed
        if actualLinesNeeded <= numberOfLines {
            return .noTruncationNeeded
        }

        // Extract target line information
        guard numberOfLines <= lineFragments.count else {
            return .noTruncationNeeded
        }

        let targetLineFragment = lineFragments[numberOfLines - 1]
        let lastLineRange = targetLineFragment.glyphRange
        let lastLineRect = targetLineFragment.rect
        let characterRange = layoutManager.characterRange(forGlyphRange: lastLineRange, actualGlyphRange: nil)

        // Generate read more text and calculate size
        let lastAttributes = lastTextAttributes(defaultAttributes: defaultAttributes)
        let readMoreWithNewLine = NSMutableAttributedString(string: newLineCharacter, attributes: lastAttributes)
        let readMoreWithOriginalAttributes = readMoreText.createMutableWithAttributes(lastAttributes)
        readMoreWithNewLine.append(readMoreWithOriginalAttributes)

        // No need to secure space for "Read More" in current line for newLine position
        // Cut text at the end of numberOfLines line
        let truncateOffset = characterRange.location + characterRange.length

        // Compose final text
        let truncatedSubstring = attributedSubstring(from: NSRange(location: 0, length: truncateOffset))
        let cleanedTruncatedText = truncatedSubstring.removingTrailingNewlineIfNeeded()
        let finalText = NSMutableAttributedString(attributedString: cleanedTruncatedText)

        finalText.append(NSAttributedString(string: newLineCharacter, attributes: lastAttributes))
        let readMoreStartLocation = finalText.length
        finalText.append(readMoreWithOriginalAttributes)

        let finalReadMoreRange = NSRange(location: readMoreStartLocation, length: readMoreWithOriginalAttributes.length)
        finalText.addAttribute(attributeKey, value: true, range: finalReadMoreRange)

        return .truncated(finalText, finalReadMoreRange)
    }

    /// Creates a configured TextKit 1 stack for text measurement and layout
    /// - Parameters:
    ///   - containerWidth: Width constraint for the text container
    ///   - lineFragmentPadding: Line fragment padding (default: 0)
    ///   - lineBreakMode: Line break mode (default: .byWordWrapping)
    ///   - maximumNumberOfLines: Maximum number of lines (default: 0 = no limit)
    /// - Returns: Tuple containing connected TextKit components
    /// Creates a configured TextKit 1 stack for text measurement and layout
    /// - Parameters:
    ///   - containerWidth: Width constraint for the text container
    ///   - lineFragmentPadding: Line fragment padding (default: 0)
    ///   - lineBreakMode: Line break mode (default: .byWordWrapping)
    ///   - maximumNumberOfLines: Maximum number of lines (default: 0 = no limit)
    /// - Returns: Tuple containing connected TextKit components
    func creatingTextKitStack(
        containerWidth: CGFloat,
        lineFragmentPadding: CGFloat = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        maximumNumberOfLines: Int = 0
    ) -> (textStorage: NSTextStorage, layoutManager: NSLayoutManager, textContainer: NSTextContainer) {
        // Create TextKit 1 components with enhanced configuration
        let textStorage = NSTextStorage(attributedString: self)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: containerWidth, height: .greatestFiniteMagnitude))

        // Enhanced connection setup with proper reference management
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)

        // Optimized container configuration
        textContainer.lineFragmentPadding = lineFragmentPadding
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = maximumNumberOfLines
        textContainer.widthTracksTextView = false
        textContainer.heightTracksTextView = false

        // Ensure layout completion for accurate measurements
        layoutManager.ensureLayout(for: textContainer)

        return (textStorage, layoutManager, textContainer)
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
