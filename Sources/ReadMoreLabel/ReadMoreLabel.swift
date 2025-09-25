import UIKit

@objc public protocol ReadMoreLabelDelegate: AnyObject {
    @objc optional func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool)
}

/// UILabel with "Read More" functionality for truncated text
@objc @IBDesignable
public class ReadMoreLabel: UILabel {
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
            refreshDisplayIfChanged(bounds.size != oldValue.size)
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
            refreshDisplayIfChanged(lineBreakMode != oldValue)
        }
    }

    override public var font: UIFont! {
        didSet {
            refreshDisplayIfChanged(font != oldValue)
        }
    }

    override public var textColor: UIColor! {
        didSet {
            refreshDisplayIfChanged(textColor != oldValue)
        }
    }

    override public var textAlignment: NSTextAlignment {
        didSet {
            refreshDisplayIfChanged(textAlignment != oldValue)
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
        setInternalNumberOfLines(numberOfLinesWhenCollapsed)
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

    private func setInternalNumberOfLines(_ lines: Int) {
        state.internalNumberOfLines = lines
        super.numberOfLines = lines
    }

    private func refreshDisplayIfChanged(_ hasChanged: Bool) {
        guard hasChanged else {
            return
        }
        reapplyTextStylingAndRefreshDisplay()
    }

    // MARK: - Helper Methods

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
    /// - Parameters:
    ///   - attributedText: The attributed text to display
    ///   - availableWidth: Available width for text layout
    private func displayTruncatedText(_ attributedText: NSAttributedString, availableWidth: CGFloat) {
        switch readMorePosition {
        case .end:
            renderEndTruncation(for: attributedText, availableWidth: availableWidth)
        case .newLine:
            renderNewLineTruncation(for: attributedText, availableWidth: availableWidth)
        }
    }

    private func makeTruncationContext(
        for attributedText: NSAttributedString,
        availableWidth: CGFloat
    ) -> TruncationContext? {
        guard attributedText.length > 0,
              availableWidth > 0,
              numberOfLinesWhenCollapsed > 0 else {
            return nil
        }

        let alignedText = aligned(attributedText)

        return TruncationContext(
            alignedText: alignedText,
            availableWidth: availableWidth,
            collapsedLineCount: numberOfLinesWhenCollapsed
        )
    }

    private func applyTruncationResult(
        _ result: TextTruncationResult,
        fallbackText: NSAttributedString,
        truncatedLineCount: Int
    ) {
        if result.needsTruncation,
           let (finalText, readMoreRange) = result.textAndRange
        {
            super.attributedText = finalText
            setInternalNumberOfLines(truncatedLineCount)
            state.readMoreTextRange = readMoreRange
        } else {
            super.attributedText = fallbackText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed)
            state.readMoreTextRange = nil
        }
    }

    private func renderEndTruncation(for attributedText: NSAttributedString, availableWidth: CGFloat) {
        guard let context = makeTruncationContext(for: attributedText, availableWidth: availableWidth) else {
            super.attributedText = attributedText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed)
            state.readMoreTextRange = nil
            return
        }

        let suffixInfo = context.alignedText.creatingReadMoreSuffix(
            ellipsisText: ellipsisText,
            readMoreText: readMoreText,
            spaceBetween: Self.defaultSpaceBetweenEllipsisAndReadMore,
            attributeKey: AttributeKey.isReadMore,
            defaultAttributes: defaultTextAttributes,
            isRTL: self.isRTL
        )

        let result = context.alignedText.applyingTruncationTextLayout(
            numberOfLines: context.collapsedLineCount,
            containerWidth: context.availableWidth,
            suffix: suffixInfo.attributedString,
            precomputedReadMoreRange: suffixInfo.readMoreRange,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode,
            isRTL: self.isRTL
        )

        applyTruncationResult(
            result,
            fallbackText: context.alignedText,
            truncatedLineCount: context.collapsedLineCount
        )
    }

    private func renderNewLineTruncation(for attributedText: NSAttributedString, availableWidth: CGFloat) {
        guard let context = makeTruncationContext(for: attributedText, availableWidth: availableWidth) else {
            super.attributedText = attributedText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed)
            state.readMoreTextRange = nil
            return
        }

        let result = context.alignedText.applyingNewLineTextLayout(
            numberOfLines: context.collapsedLineCount,
            containerWidth: context.availableWidth,
            textAlignment: textAlignment,
            font: font,
            textColor: textColor,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode,
            ellipsisText: ellipsisText,
            readMoreText: readMoreText,
            newLineCharacter: Self.newLineCharacter,
            attributeKey: AttributeKey.isReadMore,
            defaultAttributes: defaultTextAttributes,
            isRTL: self.isRTL
        )

        applyTruncationResult(
            result,
            fallbackText: context.alignedText,
            truncatedLineCount: context.collapsedLineCount + 1
        )
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
            state.updateOriginalText(aligned(originalText))
        }

        updateDisplay()
        invalidateDisplayAndLayout()
    }

    private func setOriginalText(_ text: NSAttributedString) {
        state.updateOriginalText(aligned(text))

        updateDisplay()
        invalidateDisplayAndLayout()
    }

    private func aligned(_ text: NSAttributedString) -> NSAttributedString {
        text.applyingTextAlignment(
            textAlignment,
            font: font,
            textColor: textColor
        )
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

// MARK: - ReadMoreLabel Nested Types
