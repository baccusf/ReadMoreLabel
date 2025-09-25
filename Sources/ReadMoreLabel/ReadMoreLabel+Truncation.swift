import UIKit

extension ReadMoreLabel {
    fileprivate typealias LineFragmentInfo = (fragment: NSTextLayoutFragment, lineFragment: NSTextLineFragment)

    fileprivate struct LastLineContext {
        let lineFragment: NSTextLineFragment
        let start: Int
        let range: NSRange
    }

    struct TruncationContext {
        let alignedText: NSAttributedString
        let availableWidth: CGFloat
        let collapsedLineCount: Int
    }

    fileprivate struct NewLineComponents {
        let ellipsis: NSAttributedString
        let ellipsisWidth: CGFloat
        let lineBreak: NSAttributedString
        let readMoreText: NSMutableAttributedString

        init(
            ellipsisText: NSAttributedString,
            readMoreText: NSAttributedString,
            newlineCharacter: String,
            attributes: [NSAttributedString.Key: Any],
            containerWidth: CGFloat,
            lineFragmentPadding: CGFloat,
            lineBreakMode: NSLineBreakMode,
            isRTL: Bool
        ) {
            let ellipsisWithAttributes = ellipsisText.createMutableWithAttributes(attributes)
            if ellipsisWithAttributes.length > 0 {
                ellipsisWidth = ellipsisWithAttributes.calculateTextLayoutWidth(
                    with: containerWidth,
                    lineFragmentPadding: lineFragmentPadding,
                    lineBreakMode: lineBreakMode
                )
            } else {
                ellipsisWidth = 0
            }

            ellipsis = ellipsisWithAttributes
            lineBreak = NSAttributedString(string: newlineCharacter, attributes: attributes)

            self.readMoreText = readMoreText.createMutableWithAttributes(attributes)
            if isRTL {
                self.readMoreText.append(NSAttributedString(string: "\u{200F}", attributes: attributes))
            }
        }
    }
}

private extension ReadMoreLabel.LastLineContext {
    func truncationIndex(
        precedingText: NSAttributedString,
        lastLineText: NSAttributedString,
        containerWidth: CGFloat,
        reservedWidth: CGFloat,
        isRTL: Bool
    ) -> Int {
        let maxAvailableWidth = max(0, containerWidth - reservedWidth)
        let truncatePoint = CGPoint(
            x: isRTL ? reservedWidth : maxAvailableWidth,
            y: lineFragment.typographicBounds.midY
        )

        let rawTruncateIndex = lineFragment.characterIndex(for: truncatePoint)
        let hasNewlines = precedingText.string.contains("\n") || lastLineText.string.contains("\n")
        let adjustedIndex = hasNewlines ? rawTruncateIndex : rawTruncateIndex - start
        return max(0, min(adjustedIndex, lastLineText.length))
    }
}
extension NSAttributedString {
    /// Creates mutable attributed string with base attributes
    /// - Parameter baseAttributes: Base attributes to apply
    /// - Returns: Mutable attributed string with merged attributes
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
    /// - Parameter defaultAttributes: Default attributes to use if string is empty
    /// - Returns: Attributes from last character or default attributes
    func lastTextAttributes(defaultAttributes: [NSAttributedString.Key: Any] = [:]) -> [NSAttributedString.Key: Any] {
        if length > 0 {
            attributes(at: length - 1, effectiveRange: nil)
        } else {
            defaultAttributes
        }
    }
    
    /// Calculates precise text width using TextKit 2
    /// - Parameters:
    ///   - containerWidth: Width constraint for the text container
    ///   - lineFragmentPadding: Line fragment padding (default: 0)
    ///   - lineBreakMode: Line break mode (default: .byWordWrapping)
    /// - Returns: Calculated width of the text
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
    /// - Parameters:
    ///   - textAlignment: Text alignment to apply
    ///   - font: Font to apply
    ///   - textColor: Text color to apply (optional)
    /// - Returns: Attributed string with applied styling
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
    /// - Parameters:
    ///   - location: Touch point
    ///   - range: ReadMore text range
    ///   - containerWidth: Container width
    ///   - lineFragmentPadding: Line fragment padding
    ///   - lineBreakMode: Line break mode
    ///   - readMorePosition: Position type (.end or .newLine)
    ///   - newLineCharacter: New line character
    ///   - isRTL: Whether text is right-to-left
    /// - Returns: Whether the touch hit the ReadMore text
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
    /// - Parameters:
    ///   - location: Touch location point
    ///   - range: ReadMore text range to check
    ///   - textLayoutManager: TextKit 2 layout manager
    ///   - isRTL: Whether text is right-to-left
    /// - Returns: Whether touch location is within ReadMore glyph bounds
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
    
    /// Collects TextKit 2 line fragments for layout operations
    fileprivate func collectLineFragments(
        containerWidth: CGFloat,
        lineFragmentPadding: CGFloat,
        lineBreakMode: NSLineBreakMode
    ) -> (NSTextLayoutManager, [ReadMoreLabel.LineFragmentInfo], NSTextLocation) {
        let (_, textLayoutManager, _) = creatingTextLayoutManagerStack(
            containerWidth: containerWidth,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode
        )
        
        var collectedFragments: [ReadMoreLabel.LineFragmentInfo] = []
        let documentStart = textLayoutManager.documentRange.location
        
        textLayoutManager.enumerateTextLayoutFragments(from: documentStart, options: []) { fragment in
            fragment.textLineFragments.forEach { lineFragment in
                collectedFragments.append((fragment: fragment, lineFragment: lineFragment))
            }
            return true
        }
        
        return (textLayoutManager, collectedFragments, documentStart)
    }
    
    /// Computes the layout context for the last visible line when truncating
    fileprivate func lastLineLayoutContext(
        numberOfLines: Int,
        fragments: [ReadMoreLabel.LineFragmentInfo],
        textLayoutManager: NSTextLayoutManager,
        documentStart: NSTextLocation
    ) -> ReadMoreLabel.LastLineContext? {
        guard numberOfLines < fragments.count else {
            return nil
        }
        
        let fragmentInfo = fragments[numberOfLines - 1]
        let fragmentStart = textLayoutManager.offset(
            from: documentStart,
            to: fragmentInfo.fragment.rangeInElement.location
        )
        let lineStart = fragmentStart + fragmentInfo.lineFragment.characterRange.location
        let lineRange = NSRange(
            location: lineStart,
            length: fragmentInfo.lineFragment.characterRange.length
        )
        
        return ReadMoreLabel.LastLineContext(
            lineFragment: fragmentInfo.lineFragment,
            start: lineStart,
            range: lineRange
        )
    }
    
    /// Creates ReadMore suffix with ellipsis and ReadMore text
    /// - Parameters:
    ///   - ellipsisText: Ellipsis text to prepend
    ///   - ellipsisText: Ellipsis text to append before the ReadMore line
    ///   - readMoreText: ReadMore text to append
    ///   - spaceBetween: Space character between ellipsis and ReadMore
    ///   - attributeKey: Attribute key for ReadMore identification
    ///   - defaultAttributes: Default text attributes to use
    ///   - isRTL: Whether text is right-to-left
    /// - Returns: Complete ReadMore suffix with range information
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
    
    fileprivate func prepareTruncationFragments(
        using context: ReadMoreLabel.LastLineContext,
        containerWidth: CGFloat,
        reservedWidth: CGFloat,
        isRTL: Bool
    ) -> (prefix: NSMutableAttributedString, truncatedLine: NSAttributedString) {
        let prefixRange = NSRange(location: 0, length: context.start)
        let prefixText = attributedSubstring(from: prefixRange)
        let lastLineText = attributedSubstring(from: context.range)
        let truncatedContainer = NSMutableAttributedString(attributedString: prefixText)
        
        let truncateIndex = context.truncationIndex(
            precedingText: prefixText,
            lastLineText: lastLineText,
            containerWidth: containerWidth,
            reservedWidth: reservedWidth,
            isRTL: isRTL
        )
        
        let truncatedLine = lastLineText
            .attributedSubstring(from: NSRange(location: 0, length: truncateIndex))
            .removingTrailingNewlineIfNeeded()
        
        return (truncatedContainer, truncatedLine)
    }
    
    /// Enhanced TextKit 2: Modern text truncation with NSTextLayoutFragment
    /// Uses enumerateTextLayoutFragments for precise line fragment handling
    /// - Parameters:
    ///   - numberOfLines: Maximum number of lines to display
    ///   - containerWidth: Available width for text layout
    ///   - suffix: ReadMore suffix to append
    ///   - lineFragmentPadding: Line fragment padding
    /// Modern text truncation using TextKit 2 and NSTextLayoutFragment
    /// - Parameters:
    ///   - numberOfLines: Maximum number of lines to display
    ///   - containerWidth: Available width for text layout
    ///   - suffix: ReadMore suffix to append
    ///   - precomputedReadMoreRange: Pre-calculated ReadMore range
    ///   - lineFragmentPadding: Line fragment padding (default: 0)
    ///   - lineBreakMode: Line break mode (default: .byWordWrapping)
    ///   - isRTL: Whether text is right-to-left (default: false)
    /// - Returns: TextTruncationResult with truncated text and range
    func applyingTruncationTextLayout(
        numberOfLines: Int,
        containerWidth: CGFloat,
        suffix: NSAttributedString,
        precomputedReadMoreRange: NSRange,
        lineFragmentPadding: CGFloat = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        isRTL: Bool = false
    ) -> ReadMoreLabel.TextTruncationResult {
        let (textLayoutManager, lineFragments, documentStart) = collectLineFragments(
            containerWidth: containerWidth,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode
        )
        
        guard let context = lastLineLayoutContext(
            numberOfLines: numberOfLines,
            fragments: lineFragments,
            textLayoutManager: textLayoutManager,
            documentStart: documentStart
        ) else {
            return .noTruncationNeeded
        }
        
        let suffixWidth = suffix.calculateTextLayoutWidth(
            with: containerWidth,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode
        )
        
        let (result, truncatedLine) = prepareTruncationFragments(
            using: context,
            containerWidth: containerWidth,
            reservedWidth: suffixWidth,
            isRTL: isRTL
        )
        
        result.append(truncatedLine)
        let suffixStartLocation = result.length
        result.append(suffix)
        
        let adjustedReadMoreRange = NSRange(
            location: suffixStartLocation + precomputedReadMoreRange.location,
            length: precomputedReadMoreRange.length
        )
        
        return .truncated(result, adjustedReadMoreRange)
    }
    
    /// Applies ReadMore truncation for newLine position using TextKit 2
    /// - Parameters:
    ///   - numberOfLines: Maximum number of lines to display
    ///   - containerWidth: Available width for text layout
    ///   - textAlignment: Text alignment
    ///   - font: Font to apply
    ///   - textColor: Text color to apply
    ///   - lineFragmentPadding: Line fragment padding (default: 0)
    ///   - lineBreakMode: Line break mode (default: .byWordWrapping)
    ///   - ellipsisText: Ellipsis text appended to the truncated line
    ///   - readMoreText: ReadMore text to append
    ///   - newLineCharacter: Character for new line
    ///   - attributeKey: Attribute key for ReadMore identification
    ///   - defaultAttributes: Default text attributes to use
    ///   - isRTL: Whether text is right-to-left (default: false)
    /// - Returns: TextTruncationResult with truncated text and range
    func applyingNewLineTextLayout(
        numberOfLines: Int,
        containerWidth: CGFloat,
        textAlignment: NSTextAlignment,
        font: UIFont,
        textColor: UIColor?,
        lineFragmentPadding: CGFloat = 0,
        lineBreakMode: NSLineBreakMode = .byWordWrapping,
        ellipsisText: NSAttributedString,
        readMoreText: NSAttributedString,
        newLineCharacter: String,
        attributeKey: NSAttributedString.Key,
        defaultAttributes: [NSAttributedString.Key: Any],
        isRTL: Bool = false
    ) -> ReadMoreLabel.TextTruncationResult {
        let alignedText = applyingTextAlignment(textAlignment, font: font, textColor: textColor)
        let (textLayoutManager, lineFragments, documentStart) = alignedText.collectLineFragments(
            containerWidth: containerWidth,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode
        )
        
        guard let context = alignedText.lastLineLayoutContext(
            numberOfLines: numberOfLines,
            fragments: lineFragments,
            textLayoutManager: textLayoutManager,
            documentStart: documentStart
        ) else {
            return .noTruncationNeeded
        }
        
        let lastAttributes = alignedText.lastTextAttributes(defaultAttributes: defaultAttributes)
        let components = ReadMoreLabel.NewLineComponents(
            ellipsisText: ellipsisText,
            readMoreText: readMoreText,
            newlineCharacter: newLineCharacter,
            attributes: lastAttributes,
            containerWidth: containerWidth,
            lineFragmentPadding: lineFragmentPadding,
            lineBreakMode: lineBreakMode,
            isRTL: isRTL
        )
        
        let (finalText, truncatedLine) = alignedText.prepareTruncationFragments(
            using: context,
            containerWidth: containerWidth,
            reservedWidth: components.ellipsisWidth,
            isRTL: isRTL
        )
        
        finalText.append(truncatedLine)
        
        if components.ellipsis.length > 0 {
            finalText.append(components.ellipsis)
        }
        
        finalText.append(components.lineBreak)
        
        let readMoreStartLocation = finalText.length
        finalText.append(components.readMoreText)
        
        if components.readMoreText.length > 0 {
            let finalReadMoreRange = NSRange(
                location: readMoreStartLocation,
                length: components.readMoreText.length
            )
            finalText.addAttribute(attributeKey, value: true, range: finalReadMoreRange)
            return .truncated(finalText, finalReadMoreRange)
        } else {
            return .truncated(finalText, NSRange(location: readMoreStartLocation, length: 0))
        }
    }
    
    /// Creates configured TextKit 2 stack for text measurement and layout
    /// - Parameters:
    ///   - containerWidth: Width constraint for the text container
    ///   - lineFragmentPadding: Line fragment padding (default: 0)
    ///   - lineBreakMode: Line break mode (default: .byWordWrapping)
    ///   - maximumNumberOfLines: Maximum number of lines (default: 0 for unlimited)
    /// - Returns: Tuple containing connected TextKit 2 components
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
        
        // Clear existing layout fragments to keep line metrics deterministic
        textLayoutManager.ensureLayout(for: documentRange)
        
        return (textContentStorage, textLayoutManager, textContainer)
    }
}
