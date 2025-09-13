import UIKit

// MARK: - Public Protocols

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
            guard state.setExpanded(newValue) else {
                return
            }
            updateDisplay()
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

    /// Detects RTL (Right-to-Left) language environment
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

    /// Sets expansion state with delegate notification control
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
        if let existingGesture = tapGestureRecognizer {
            removeGestureRecognizer(existingGesture)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGestureRecognizer = tapGesture
        addGestureRecognizer(tapGesture)
    }

    /// Handles display updates when configuration changes
    private func handleConfigurationChange() {
        updateDisplay()
        invalidateDisplayAndLayout()
    }

    private func applyReadMore(
        originalText: NSAttributedString,
        numberOfLines: Int,
        containerWidth: CGFloat,
        suffix: NSAttributedString,
        precomputedReadMoreRange: NSRange,
        isRTL: Bool = false
    ) -> TextTruncationResult {
        let alignedText = originalText.applyingTextAlignment(textAlignment, font: font, textColor: textColor)
        
        if readMorePosition == .newLine {
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
            return alignedText.applyingReadMoreTruncation(
                numberOfLines: numberOfLines,
                containerWidth: containerWidth,
                suffix: suffix,
                precomputedReadMoreRange: precomputedReadMoreRange,
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

    // MARK: - Helper Methods
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

    /// Validates and returns display state
    private func validateDisplayState() -> (attributedText: NSAttributedString, availableWidth: CGFloat)? {
        let availableWidth = bounds.width
        guard availableWidth > 0,
              let attributedTextToDisplay = state.originalText,
              attributedTextToDisplay.length > 0 else
        {
            return nil
        }

        return (attributedTextToDisplay, availableWidth)
    }

    /// Determines if text should be displayed in expanded form
    private func shouldDisplayExpandedText() -> Bool {
        isExpanded || numberOfLinesWhenCollapsed == 0
    }

    /// Handles text display in expanded state
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

        let suffixInfo = attributedText.creatingReadMoreSuffix(
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
            suffix: suffixInfo.attributedString,
            precomputedReadMoreRange: suffixInfo.readMoreRange,
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
            setExpanded(true, notifyDelegate: true)
        }
    }

    private func invalidateDisplayAndLayout() {
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    /// Reapplies text styling and refreshes display
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
    /// Creates mutable attributed string with base attributes
    func createMutableWithAttributes(_ baseAttributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
        let mutableString = NSMutableAttributedString(attributedString: self)
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

    /// Returns last character attributes or default values
    func lastTextAttributes(defaultAttributes: [NSAttributedString.Key: Any] = [:]) -> [NSAttributedString.Key: Any] {
        if length > 0 {
            attributes(at: length - 1, effectiveRange: nil)
        } else {
            defaultAttributes
        }
    }

    /// Calculates precise text width using TextKit 2
    func calculateTextLayoutWidth(
        with containerWidth: CGFloat,
        lineFragmentPadding: CGFloat = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping
    ) -> CGFloat {
        let (textContentStorage, textLayoutManager, textContainer) = creatingTextLayoutManagerStack(
            containerWidth: containerWidth,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode
        )

        var maxWidth: CGFloat = 0
        let documentRange = textLayoutManager.documentRange
        
        textLayoutManager.enumerateTextLayoutFragments(from: documentRange.location, options: []) { fragment in
            let fragmentWidth = fragment.layoutFragmentFrame.width
            maxWidth = max(maxWidth, fragmentWidth)
            return true
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

    /// Applies text alignment, font, and color attributes
    func applyingTextAlignment(_ textAlignment: NSTextAlignment, font: UIFont,
                               textColor: UIColor? = nil) -> NSAttributedString
    {
        let range = NSRange(location: 0, length: length)
        let mutableAttributedText = NSMutableAttributedString(attributedString: self)
        mutableAttributedText.addAttribute(.font, value: font, range: range)

        if let textColor {
            mutableAttributedText.addAttribute(.foregroundColor, value: textColor, range: range)
        }

        if let existingStyle = attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle,
           existingStyle.alignment == textAlignment
        {
            return mutableAttributedText
        }

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

    /// Precise hit testing using TextKit 2 based on glyph bounds
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

        textLayoutManager.ensureLayout(for: textLayoutManager.documentRange)
        return isLocationInReadMoreGlyphBounds(
            location: location,
            range: range,
            textLayoutManager: textLayoutManager,
            isRTL: isRTL
        )
    }
    
    /// ReadMore touch detection with BiDi text support
    private func isLocationInReadMoreGlyphBounds(
        location: CGPoint,
        range: NSRange,
        textLayoutManager: NSTextLayoutManager,
        isRTL: Bool
    ) -> Bool {
        guard let attributedText = (textLayoutManager.textContentManager as? NSTextContentStorage)?.attributedString else {
            return false
        }
        
        var characterIndex: Int = NSNotFound
        let documentStart = textLayoutManager.documentRange.location
        
        textLayoutManager.enumerateTextLayoutFragments(from: documentStart, options: []) { fragment in
            let fragmentFrame = fragment.layoutFragmentFrame
            
            guard fragmentFrame.contains(location) else {
                return true
            }
            
            for lineFragment in fragment.textLineFragments {
                let lineRect = CGRect(
                    x: fragmentFrame.origin.x + lineFragment.typographicBounds.origin.x,
                    y: fragmentFrame.origin.y + lineFragment.typographicBounds.origin.y,
                    width: lineFragment.typographicBounds.width,
                    height: lineFragment.typographicBounds.height
                )
                
                guard lineRect.contains(location) else {
                    continue
                }
                
                let relativeLocation = CGPoint(
                    x: location.x - lineRect.origin.x,
                    y: location.y - lineRect.origin.y
                )
                
                let characterIndexInLine = lineFragment.characterIndex(for: relativeLocation)
                if characterIndexInLine != NSNotFound {
                    let fragmentStartIndex = textLayoutManager.offset(from: documentStart, to: fragment.rangeInElement.location)
                    characterIndex = fragmentStartIndex + characterIndexInLine
                    return false
                }
            }
            
            return true
        }
        
        guard characterIndex != NSNotFound,
              characterIndex >= 0,
              characterIndex < attributedText.length,
              NSLocationInRange(characterIndex, range) else {
            return false
        }
        
        let attributes = attributedText.attributes(at: characterIndex, effectiveRange: nil)
        return (attributes[ReadMoreLabel.AttributeKey.isReadMore] as? Bool) == true
    }
    
    /// Creates ReadMore suffix with ellipsis and ReadMore text
    func creatingReadMoreSuffix(
        ellipsisText: NSAttributedString,
        readMoreText: NSAttributedString,
        spaceBetween: String,
        attributeKey: NSAttributedString.Key,
        defaultAttributes: [NSAttributedString.Key: Any],
        isRTL: Bool
    ) -> (attributedString: NSAttributedString, readMoreRange: NSRange) {
        let lastAttributes = lastTextAttributes(defaultAttributes: defaultAttributes)

        let suffix = NSMutableAttributedString()
        let ellipsisWithLastAttributes = ellipsisText.createMutableWithAttributes(lastAttributes)

        // Component ordering and spacing based on RTL/LTR
        suffix.append(ellipsisWithLastAttributes) // ".."
        suffix.append(NSAttributedString(string: isRTL ? "\u{00A0}" : spaceBetween, attributes: lastAttributes)) // NBSP
        
        // ReadMore text processing (common logic)
        let readMoreStartLocation = suffix.length
        let readMoreWithOriginalAttributes = readMoreText.createMutableWithAttributes(lastAttributes)
        
        // Add RLM for BiDi neutral character handling in RTL only
        if isRTL {
            readMoreWithOriginalAttributes.append(NSAttributedString(string: "\u{200F}", attributes: lastAttributes)) // RLM
        }
        
        suffix.append(readMoreWithOriginalAttributes)
        
        // Set readMore range (using actual length considering RLM character addition)
        let readMoreRange = NSRange(
            location: readMoreStartLocation, 
            length: readMoreWithOriginalAttributes.length
        )
        
        suffix.addAttribute(attributeKey, value: true, range: readMoreRange)

        return (attributedString: suffix, readMoreRange: readMoreRange)
    }

    /// Enhanced TextKit 2: Modern text truncation with NSTextLayoutFragment
    /// Uses enumerateTextLayoutFragments for precise line fragment handling
    /// - Parameters:
    ///   - numberOfLines: Maximum number of lines to display
    ///   - containerWidth: Available width for text layout
    ///   - suffix: ReadMore suffix to append
    ///   - lineFragmentPadding: Line fragment padding
    /// Modern text truncation using TextKit 2 and NSTextLayoutFragment
    func applyingReadMoreTruncation(
        numberOfLines: Int,
        containerWidth: CGFloat,
        suffix: NSAttributedString,
        precomputedReadMoreRange: NSRange,
        lineFragmentPadding: CGFloat = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        isRTL: Bool = false
    ) -> ReadMoreLabel.TextTruncationResult {
        let (_, textLayoutManager, _) = creatingTextLayoutManagerStack(
            containerWidth: containerWidth,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode
        )

        var allLineFragments: [(fragment: NSTextLayoutFragment, lineFragment: NSTextLineFragment)] = []
        let documentStart = textLayoutManager.documentRange.location
        
        textLayoutManager.enumerateTextLayoutFragments(from: documentStart, options: []) { fragment in
            for lineFragment in fragment.textLineFragments {
                allLineFragments.append((fragment: fragment, lineFragment: lineFragment))
            }
            return true
        }
        
        guard numberOfLines < allLineFragments.count else {
            return .noTruncationNeeded
        }
        
        let (lastFragment, lastLineFragment) = allLineFragments[numberOfLines - 1]
        let lastLineStart = textLayoutManager.offset(from: documentStart, 
                                                   to: lastFragment.rangeInElement.location) + lastLineFragment.characterRange.location
        
        let result = NSMutableAttributedString(attributedString: attributedSubstring(from: NSRange(location: 0, length: lastLineStart)))
        let lastLineRange = NSRange(location: lastLineStart, length: lastLineFragment.characterRange.length)
        let lastLineText = attributedSubstring(from: lastLineRange)
        
        
        let suffixWidth = suffix.calculateTextLayoutWidth(
            with: containerWidth,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode
        )
        
        let lastLineUsedWidth = lastLineFragment.typographicBounds.width
        let maxAvailableWidth = containerWidth - suffixWidth
        
        let truncatePoint: CGPoint
        if isRTL {
            truncatePoint = CGPoint(x: suffixWidth, y: lastLineFragment.typographicBounds.midY)
        } else {
            truncatePoint = CGPoint(x: maxAvailableWidth, y: lastLineFragment.typographicBounds.midY)
        }

        let rawTruncateIndex = lastLineFragment.characterIndex(for: truncatePoint)
        let hasNewlines = result.string.contains("\n") || lastLineText.string.contains("\n")
        let adjustedIndex = hasNewlines ? rawTruncateIndex : rawTruncateIndex - lastLineStart
        let truncateIndex = max(0, min(adjustedIndex, lastLineText.length))
        
        let truncated = lastLineText.attributedSubstring(from: NSRange(location: 0, length: truncateIndex)).removingTrailingNewlineIfNeeded()
        result.append(truncated)
        let suffixStartLocation = result.length
        result.append(suffix)

        let adjustedReadMoreRange = NSRange(
            location: suffixStartLocation + precomputedReadMoreRange.location,
            length: precomputedReadMoreRange.length
        )
        
        return .truncated(result, adjustedReadMoreRange)
    }

    /// Applies ReadMore truncation for newLine position using TextKit 2
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

        var allLineFragments: [(fragment: NSTextLayoutFragment, lineFragment: NSTextLineFragment)] = []
        let documentStart = textLayoutManager.documentRange.location
        
        textLayoutManager.enumerateTextLayoutFragments(from: documentStart, options: []) { fragment in
            for lineFragment in fragment.textLineFragments {
                allLineFragments.append((fragment: fragment, lineFragment: lineFragment))
            }
            return true
        }

        guard numberOfLines < allLineFragments.count else {
            return .noTruncationNeeded
        }

        let (lastFragment, lastLineFragment) = allLineFragments[numberOfLines - 1]
        let lastLineStart = textLayoutManager.offset(from: documentStart, 
                                                   to: lastFragment.rangeInElement.location) + lastLineFragment.characterRange.location
        let lastLineRange = NSRange(location: lastLineStart, length: lastLineFragment.characterRange.length)
        
        let truncateOffset = lastLineRange.location + lastLineRange.length
        let truncatedSubstring = attributedSubstring(from: NSRange(location: 0, length: truncateOffset))
        let cleanedTruncatedText = truncatedSubstring.removingTrailingNewlineIfNeeded()
        
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

    /// Creates configured TextKit 2 stack for text measurement and layout
    func creatingTextLayoutManagerStack(
        containerWidth: CGFloat,
        lineFragmentPadding: CGFloat = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        maximumNumberOfLines: Int = 0
    ) -> (textContentStorage: NSTextContentStorage, textLayoutManager: NSTextLayoutManager, textContainer: NSTextContainer) {
        let textContentStorage = NSTextContentStorage()
        let textLayoutManager = NSTextLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: containerWidth, height: .greatestFiniteMagnitude))

        textContentStorage.attributedString = NSAttributedString(attributedString: self)

        textContentStorage.addTextLayoutManager(textLayoutManager)
        textLayoutManager.textContainer = textContainer

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

    /// Manages layout configuration state
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

    /// Composite state management for ReadMoreLabel
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
